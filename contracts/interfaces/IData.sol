pragma ton-solidity >= 0.43.0;

interface IData {
    function transferOwnership(address addrTo) external;
    function transferOwnershipAndNotify(address addrTo, TvmCell payload) external;

    function getOwner() external view returns (address addrOwner);
    function getInfo() external view returns (
        address addrRoot,
        address addrOwner,
        address addrData
    );
}
