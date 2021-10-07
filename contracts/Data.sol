pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';

import './interfaces/IData.sol';
import './interfaces/INftRoot.sol';
import './interfaces/IReceiveNftCallback.sol';

import './libraries/Constants.sol';
import './errors/DataErrors.sol';


contract Data is IData, IndexResolver {
    address _addrRoot;
    address _addrOwner;
    address _addrAuthor;

    bytes _dataUrl;
    uint256 static _id;

    event OwnershipTrasfered(address dataAddress, uint256 id);

    constructor(address addrOwner, bytes dataUrl, TvmCell codeIndex) public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), DataErrors.NO_CODE_SALT);
        (address addrRoot) = optSalt.get().toSlice().decode(address);
        require(msg.sender == addrRoot, DataErrors.SENDER_IS_NOT_OWNER);
        require(msg.value >= Constants.DATA_DEPLOY_VALUE, DataErrors.NOT_ENOUGH_VALUE);
        tvm.accept();
        tvm.rawReserve(Constants.DATA_INITIAL_VALUE, 0);
        _dataUrl = dataUrl;
        _addrRoot = addrRoot;
        _addrOwner = addrOwner;
        _addrAuthor = addrOwner;
        _codeIndex = codeIndex;

        deployIndex(addrOwner);
    }

    function transferOwnership(address addrTo) public override {
        require(msg.sender == _addrOwner);
        require(msg.value >= Constants.TRANSFER_OWNERSHIP_VALUE);
        tvm.rawReserve(Constants.DATA_INITIAL_VALUE, 0);

        address oldIndexOwner = resolveIndex(_addrRoot, address(this), _addrOwner);
        IIndex(oldIndexOwner).destruct();
        address oldIndexOwnerRoot = resolveIndex(address(0), address(this), _addrOwner);
        IIndex(oldIndexOwnerRoot).destruct();
        _addrOwner.transfer({ value: 0, flag: 128, bounce: false });
        _addrOwner = addrTo;
        deployIndex(addrTo);
    }


    function transfer(
        address addrTo,
        bool notify,
        TvmCell payload,
        address sendGasTo
    ) public override {
        require(msg.sender == _addrOwner, DataErrors.SENDER_IS_NOT_OWNER);
        require(msg.value >= Constants.TRANSFER_OWNERSHIP_VALUE, DataErrors.NOT_ENOUGH_VALUE);
        tvm.rawReserve(Constants.DATA_INITIAL_VALUE, 0);

        address oldIndexOwner = resolveIndex(_addrRoot, address(this), _addrOwner);
        IIndex(oldIndexOwner).destruct();
        address oldIndexOwnerRoot = resolveIndex(address(0), address(this), _addrOwner);
        IIndex(oldIndexOwnerRoot).destruct();

        _addrOwner = addrTo;

        deployIndex(addrTo);
        emit OwnershipTrasfered(address(this), _id);
        if (notify) {
            IReceiveNftCallback(addrTo).onReceiveNft{ value: 0, flag: 128, bounce: false }(
                address(this),
                _addrRoot,
                _id,
                msg.sender,
                payload,
                sendGasTo
            );
        } else {
            sendGasTo.transfer({ value: 0, flag: 128, bounce: false });
        }
        
    }

    
    function burn(
        address sendGasTo
    ) public {
        require(msg.sender == _addrOwner, DataErrors.SENDER_IS_NOT_OWNER);
        address oldIndexOwner = resolveIndex(_addrRoot, address(this), _addrOwner);
        IIndex(oldIndexOwner).destruct();
        address oldIndexOwnerRoot = resolveIndex(address(0), address(this), _addrOwner);
        IIndex(oldIndexOwnerRoot).destruct();
        INftRoot(_addrRoot).burnNotify{ value: 0, flag: 128 + 32}(_id, sendGasTo);
    }
    

    function deployIndex(address owner) private {
        TvmCell codeIndexOwner = _buildIndexCode(_addrRoot, owner);
        TvmCell stateIndexOwner = _buildIndexState(codeIndexOwner, address(this));
        new Index{stateInit: stateIndexOwner, value: 0.4 ton}(_addrRoot);

        TvmCell codeIndexOwnerRoot = _buildIndexCode(address(0), owner);
        TvmCell stateIndexOwnerRoot = _buildIndexState(codeIndexOwnerRoot, address(this));
        new Index{stateInit: stateIndexOwnerRoot, value: 0.4 ton}(_addrRoot);
    }

    function getInfo() public view responsible override returns (
        address addrRoot,
        address addrOwner,
        address addrData
    ) {
        addrRoot = _addrRoot;
        addrOwner = _addrOwner;
        addrData = address(this);

    }

    function getDetails() public view responsible override returns (
        bytes dataUrl
    ) {
        dataUrl = _dataUrl;
    }

    function getOwner() public view override returns(address addrOwner) {
        addrOwner = _addrOwner;
    }

    function getVersion() public view responsible returns (uint version) {
        return 1;
    }
}