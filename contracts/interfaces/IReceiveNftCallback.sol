pragma ton-solidity >= 0.43.0;

interface IReceiveNftCallback {
    function onReceiveNft(
        address data_address,
        address data_root,
        uint256 data_id,
        address sender_address,
        TvmCell payload,
        address send_gas_to
    ) external;
}