pragma ton-solidity >= 0.43.0;

interface INftRoot {
    function burnNotify(uint256 id, address sendGasTo) external;
}