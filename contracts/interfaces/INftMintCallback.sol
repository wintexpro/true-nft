pragma ton-solidity >= 0.43.0;

interface INftMintCallback {
    function onMintNft(
        address dataAddress,
        address dataRoot,
        uint256 dataId,
        address sendGasTo
    ) external;
}