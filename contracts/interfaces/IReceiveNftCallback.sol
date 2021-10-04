pragma ton-solidity >= 0.43.0;

interface IReceiveNftCallback {
    function onReceiveNft(address data_address, address sender_address, TvmCell payload) external;
}