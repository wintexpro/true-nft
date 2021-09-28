pragma ton-solidity >= 0.43.0;

interface IReceiveNftCallback {
    function onReceiveNft(TvmCell payload) external;
}