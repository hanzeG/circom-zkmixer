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

import "./MerkleTreeWithHistory.sol";
import "./ReentrancyGuard.sol";

// todo: verification key

// interface IVerifier1 {
//     function verifyProof(
//         bytes memory _proof,
//         uint256[6] memory _input,
//         uint8[4] memory _receiptOrder,
//         uint256[15] memory _receipt1,
//         uint256[15] memory _receipt2,
//         uint256[15] memory _receipt3,
//         uint256[15] memory _receipt4
//     ) external returns (bool);
// }

// interface IVerifier2 {
//     function verifyProof(bytes memory _proof) external returns (bool);
// }

interface IVerifier {
    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[1] calldata _pubSignals
    ) external returns (bool);
}

abstract contract Tornado is MerkleTreeWithHistory, ReentrancyGuard {
    IVerifier public immutable verifier1;
    IVerifier public immutable verifier2;
    uint256[4] public denominations;

    mapping(bytes32 => bool) public nullifierHashes;
    // we store all commitments just to prevent accidental deposits with the same commitment
    mapping(bytes32 => bool) public commitments;

    event Deposit(bytes32 indexed userCommitment, uint256 timestamp);
    event Commit(
        bytes32 indexed userCommitment,
        uint32 insertedIndex,
        uint256 timestamp
    );
    event Withdrawal(
        bytes32 nullifierHash,
        address indexed relayer,
        uint256 fee
    );

    /**
    @dev The constructor
    @param _verifier1 the address of SNARK verifier for this contract
    @param _verifier2 the address of SNARK verifier for this contract
    @param _hasher the address of MiMC hash contract
    @param _denominations transfer amount for each deposit
    @param _merkleTreeHeight the height of deposits' Merkle Tree
  */
    constructor(
        IVerifier _verifier1,
        IVerifier _verifier2,
        IHasher _hasher,
        uint256[4] memory _denominations,
        uint32 _merkleTreeHeight
    ) MerkleTreeWithHistory(_merkleTreeHeight, _hasher) {
        for (uint8 i = 0; i < 4; i++) {
            require(
                _denominations[i] > 0,
                "all denomination should be greater than 0"
            );
        }
        verifier1 = _verifier1;
        verifier2 = _verifier2;
        denominations = _denominations;
    }

    /**
    @dev Deposit funds into the contract. The caller must send (for ETH) or approve (for ERC20) value equal to or `denomination` of this instance.
    @param _userCommitment the note commitment, which is PedersenHash(nullifier, secret)
  */
    function deposit(bytes32 _userCommitment) external payable nonReentrant {
        // 调用独立的函数提取金额并转换为长度为4的uint8数组
        uint8[4] memory amountDigits = extractAmountAndConvertToDigits(
            _userCommitment
        );

        // 从digits数组还原出amount值，以便进行金额验证
        uint256 amount = reconstructAmountFromDigits(amountDigits);

        // 示例：如果最后两个字节是 0x0001，那么 amount 将是 1
        require(
            amount > 0,
            "Amount extracted from commitment must be greater than 0"
        );
        _processDeposit(amount);

        emit Deposit(_userCommitment, block.timestamp);
    }

    /**
    @dev Aggerate user commitments into the contract.
    @param _commitment the sequencer's note commitment, which is slot root
  */
    function commit(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[1] calldata _pubSignals,
        bytes32 _commitment
    ) external payable nonReentrant {
        require(!commitments[_commitment], "The commitment has been submitted");

        require(
            verifier1.verifyProof(_pA, _pB, _pC, _pubSignals),
            "Invalid commit proof"
        );

        uint32 insertedIndex = _insert(_commitment);
        commitments[_commitment] = true;

        emit Commit(_commitment, insertedIndex, block.timestamp);
    }

    /** @dev this function is defined in a child contract */
    function _processDeposit(uint256 _amount) internal virtual;

    /**
    @dev Withdraw a deposit from the contract. `proof` is a zkSNARK proof data, and input is an array of circuit public inputs
    `input` array consists of:
      - merkle root of all deposits in the contract
      - hash of unique deposit nullifier to prevent double spends
      - the recipient of funds
      - optional fee that goes to the transaction sender (usually a relay)
  */
    function withdraw(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[1] calldata _pubSignals,
        bytes32 _root,
        bytes32 _nullifierHash,
        uint8[4] memory _receiptOrder,
        address payable[15][4] memory _recipient,
        address payable _relayer,
        uint256 _amount,
        uint256 _fee,
        uint256 _refund
    ) external payable nonReentrant {
        for (uint8 i = 0; i < 4; i++) {
            require(_fee <= denominations[i], "Fee exceeds transfer value");
        }
        require(
            !nullifierHashes[_nullifierHash],
            "The note has been already spent"
        );
        require(isKnownRoot(_root), "Cannot find your merkle root"); // Make sure to use a recent one

        // require(
        //     verifier.verifyProof(
        //         _proof,
        //         [
        //             uint256(_root),
        //             uint256(_nullifierHash),
        //             uint256(_relayer),
        //             _amount,
        //             _fee,
        //             _refund
        //         ],
        //         _receiptOrder,
        //         convertAddressesToUint256(_recipient1),
        //         convertAddressesToUint256(_recipient2),
        //         convertAddressesToUint256(_recipient3),
        //         convertAddressesToUint256(_recipient4)
        //     ),
        //     "Invalid withdraw proof"
        // );

        require(
            verifier2.verifyProof(_pA, _pB, _pC, _pubSignals),
            "Invalid withdraw proof"
        );

        nullifierHashes[_nullifierHash] = true;
        _processWithdraw(
            _receiptOrder,
            _recipient,
            _relayer,
            _amount,
            _fee,
            _refund
        );
        emit Withdrawal(_nullifierHash, _relayer, _fee);
    }

    /** @dev this function is defined in a child contract */
    function _processWithdraw(
        uint8[4] memory _receiptOrder,
        address payable[15][4] memory _recipient,
        address payable _relayer,
        uint256 _amount,
        uint256 _fee,
        uint256 _refund
    ) internal virtual;

    /** @dev whether a note is already spent */
    function isSpent(bytes32 _nullifierHash) public view returns (bool) {
        return nullifierHashes[_nullifierHash];
    }

    /** @dev whether an array of notes is already spent */
    function isSpentArray(
        bytes32[] calldata _nullifierHashes
    ) external view returns (bool[] memory spent) {
        spent = new bool[](_nullifierHashes.length);
        for (uint256 i = 0; i < _nullifierHashes.length; i++) {
            if (isSpent(_nullifierHashes[i])) {
                spent[i] = true;
            }
        }
    }

    /** @dev calculate amuont from digits */
    function reconstructAmountFromDigits(
        uint8[4] memory digits
    ) internal pure returns (uint256 amount) {
        amount =
            uint256(digits[0]) *
            1000 +
            uint256(digits[1]) *
            100 +
            uint256(digits[2]) *
            10 +
            uint256(digits[3]);
    }

    /** @dev commitment checksum */
    function extractAmountAndConvertToDigits(
        bytes32 _commitment
    ) internal pure returns (uint8[4] memory digits) {
        uint256 amount = uint256(_commitment) & 0xFFFF; // last 2 bytes

        digits = [uint8(0), uint8(0), uint8(0), uint8(0)];

        if (amount == 0) {
            return digits;
        }

        // 将amount转换为十进制数字并存储在临时数组中，数字顺序为从最低位到最高位
        uint8[5] memory tempDigits; // amount最大为65535，最多5位数字
        uint8 numDigits = 0;
        uint256 tempAmount = amount;

        while (tempAmount > 0) {
            tempDigits[numDigits] = uint8(tempAmount % 10);
            tempAmount = tempAmount / 10;
            numDigits++;
        }

        // 根据数字位数处理digits数组
        if (numDigits <= 4) {
            // 数字位数小于等于4，前面用0填充
            for (uint8 i = 0; i < numDigits; i++) {
                digits[3 - i] = tempDigits[i]; // 从digits的末尾开始填充
            }
        } else {
            // 数字位数超过4，将最高两位数字合并到digits[0]
            digits[0] = uint8(
                tempDigits[numDigits - 1] * 10 + tempDigits[numDigits - 2]
            ); // 合并最高两位数字
            digits[1] = tempDigits[numDigits - 3];
            digits[2] = tempDigits[numDigits - 4];
            digits[3] = tempDigits[numDigits - 5];
        }

        return digits;
    }

    function convertAddressesToUint256(
        address payable[15] memory _recipient
    ) public pure returns (uint256[15] memory) {
        // 初始化 uint256 数组
        uint256[15] memory result;

        // 遍历 _recipient 并将每个地址转换为 uint256
        for (uint8 i = 0; i < 15; i++) {
            result[i] = uint256(uint160(_recipient[i])); // address => uint160 => uint256
        }

        return result;
    }
}
