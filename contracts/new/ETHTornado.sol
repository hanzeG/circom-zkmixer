// https://tornado.cash
/*
 * d888888P                                           dP              a88888b.                   dP
 *    88                                              88             d8'   `88                   88
 *    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
 *    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
 *    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
 *    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
 * ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./Tornado.sol";

contract ETHTornado is Tornado {
    constructor(
        IVerifier _verifier1,
        IVerifier _verifier2,
        IHasher _hasher,
        uint256[4] memory _denomination,
        uint32 _merkleTreeHeight
    )
        Tornado(
            _verifier1,
            _verifier2,
            _hasher,
            _denomination,
            _merkleTreeHeight
        )
    {}

    function _processDeposit(uint256 _amount) internal override {
        require(
            msg.value == _amount,
            "Please send correct ETH along with transaction"
        );
    }

    function _processWithdraw(
        uint8[4] memory _receiptOrder,
        address payable[15][4] memory _recipient,
        address payable _relayer,
        uint256 _amount,
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

        uint256 totalTransferAmount = 0;

        // Transfer to _recipient
        for (uint8 i = 0; i < 4; i++) {
            uint8 numRecipients = _receiptOrder[i];
            for (uint8 j = 0; j < numRecipients; j++) {
                address payable recipient = _recipient[i][j];
                (bool success, ) = recipient.call{value: denominations[i]}("");
                require(success, "Transfer to _recipient failed");
                totalTransferAmount += denominations[i];
            }
        }

        // Pay the fee to the relayer
        if (_fee > 0) {
            (bool success, ) = _relayer.call{value: _fee}("");
            require(success, "Payment to relayer failed");
        }

        // Ensure total transfers and fee do not exceed the amount
        require(
            totalTransferAmount + _fee <= _amount,
            "Insufficient funds for transfers and fee"
        );
    }
}
