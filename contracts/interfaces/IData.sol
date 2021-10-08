pragma ton-solidity >= 0.43.0;

interface IData {
    event OwnershipTrasfered(address dataAddress, uint256 id);
    event Minted(address dataAddress, uint256 id);
    event Burned(address dataAddress, uint256 id);
    
    function transferOwnership(address addrTo) external;
    function transfer(
        address addrTo,
        bool notify,
        TvmCell payload,
        address sendGasTo
    ) external;

    function getOwner() external view returns (address addrOwner);
    function getInfo() external view responsible returns (
        address addrRoot,
        address addrOwner,
        address addrData
    );
    function getDetails() external view responsible returns (
        bytes dataUrl
    );
}
