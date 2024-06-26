// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./protocol.sol";

contract ETHTornado is Protocol {
    constructor(
        IVerifier _verifier1,
        IVerifier _verifier2,
        IHasher _hasher,
        uint256 _denomination,
        uint32 _merkleTreeHeight
    )
        Protocol(
            _verifier1,
            _verifier2,
            _hasher,
            _denomination,
            _merkleTreeHeight
        )
    {}

    function _processDeposit() internal override {
        require(
            msg.value == denomination,
            "Please send `mixDenomination` ETH along with transaction"
        );
    }

    function _processWithdraw(
        address payable _recipient,
        address payable _relayer,
        uint256 _fee,
        uint256 _refund
    ) internal override {
        // sanity checks
        require(
            msg.value == 0,
            "Message value is supposed to be zero for ETH instance"
        );
        require(
            _refund == 0,
            "Refund value is supposed to be zero for ETH instance"
        );

        (bool success, ) = _recipient.call{value: denomination - _fee}("");
        require(success, "payment to _recipient did not go thru");
        if (_fee > 0) {
            (success, ) = _relayer.call{value: _fee}("");
            require(success, "payment to _relayer did not go thru");
        }
    }
}
