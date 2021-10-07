pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './errors/IndexErrors.sol';

contract IndexBasis {
    address static _addrRoot;
    uint256 static _codeHashData;

    modifier onlyRoot() {
        require(msg.sender == _addrRoot, IndexErrors.SENDER_IS_NOT_ROOT);
        tvm.accept();
        _;
    }

    constructor() public {
        if (msg.sender != _addrRoot) {
            msg.sender.transfer({ value: 0, flag: 128 + 32, bounce: false });
        }
    }

    function getInfo() public view returns (address addrRoot, uint256 codeHashData) {
        addrRoot = _addrRoot;
        codeHashData = _codeHashData;
    }

    function destruct() public onlyRoot {
        selfdestruct(_addrRoot);
    }
}