pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';
import './resolvers/DataResolver.sol';

import './IndexBasis.sol';

import './interfaces/IData.sol';
import './interfaces/IIndexBasis.sol';

import './libraries/Constants.sol';
import './errors/NftRootErrors.sol';

import './access/InternalOwner.sol';

contract NftRoot is DataResolver, IndexResolver, InternalOwner {

    uint256 _totalSupply;
    uint256 _totalMinted;
    address _addrBasis;

    event DataMinted(address dataAddress, uint256 id);
    event DataBurned(address dataAddress, uint256 id);

    constructor(
        TvmCell codeIndex,
        TvmCell codeData,
        address internalOwner,
        address sendGasTo
    ) public {
        tvm.accept();
        tvm.rawReserve(Constants.ROOT_INITIAL_VALUE, 0);
        _codeIndex = codeIndex;
        _codeData = codeData;
        owner = internalOwner;
        sendGasTo.transfer({ value: 0, flag: 128, bounce: false });
    }

    function mintNft(
        bytes dataUrl,
        address sendGasTo
    ) public onlyOwner {
        require(msg.value >= Constants.MINT_NFT_VALUE, NftRootErrors.NOT_ENOUGH_VALUE);
        tvm.rawReserve(Constants.ROOT_INITIAL_VALUE, 0);
        TvmCell codeData = _buildDataCode(address(this));
        TvmCell stateData = _buildDataState(codeData, _totalMinted);
        address newDataAddress = new Data{stateInit: stateData, value: Constants.DATA_DEPLOY_GAS}(msg.sender, dataUrl, _codeIndex);
        emit DataMinted(newDataAddress, _totalMinted);
        _totalMinted++;
        _totalSupply++;
        sendGasTo.transfer({ value: 0, flag: 128, bounce: false });
    }

    function deployBasis(
        TvmCell codeIndexBasis,
        address sendGasTo
    ) public {
        require(msg.value >= Constants.DEPLOY_BASIS_VALUE, NftRootErrors.NOT_ENOUGH_VALUE);
        tvm.rawReserve(Constants.ROOT_INITIAL_VALUE, 0);
        uint256 codeHasData = resolveCodeHashData();
        TvmCell state = tvm.buildStateInit({
            contr: IndexBasis,
            varInit: {
                _codeHashData: codeHasData,
                _addrRoot: address(this)
            },
            code: codeIndexBasis
        });
        _addrBasis = new IndexBasis{stateInit: state, value: Constants.INDEX_BASIS_INITIAL_VALUE}();
        sendGasTo.transfer({ value: 0, flag: 128, bounce: false });
    }

    function destructBasis(
        address sendGasTo
    ) public view {
        require(msg.value >= Constants.DESTRUCT_BASIS_VALUE, NftRootErrors.NOT_ENOUGH_VALUE);
        tvm.rawReserve(Constants.ROOT_INITIAL_VALUE, 0);
        IIndexBasis(_addrBasis).destruct();
        sendGasTo.transfer({ value: 0, flag: 128, bounce: false });
    }

    function burnNotify(
        uint256 id,
        address sendGasTo
    ) external {
        require(msg.sender == resolveData(address(this), id), NftRootErrors.WRONG_DATA_SENDER);
        _totalSupply--;
        emit DataBurned(msg.sender, id);
        sendGasTo.transfer({ value: 0, flag: 128, bounce: false});
    }

    function getVersion() public view responsible returns (uint version) {
        return 1;
    }
}