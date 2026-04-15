// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainSignatureVerifier {
    function verifySignature(
        address _signer,
        bytes32 _message,
        bytes calldata _signature
    ) external pure returns (bool) {
        bytes32 ethSignedMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _message));
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        address recovered = ecrecover(ethSignedMessage, v, r, s);
        return recovered == _signer;
    }

    function splitSignature(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "Invalid signature");
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }

    function getMessageHash(string calldata _message) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }
}
