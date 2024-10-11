// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./MerkleTreeWithHistory.sol";
import "./ReentrancyGuard.sol";

// 接口定义
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

    // 定义结构体以减少变量数量
    struct Proof {
        uint[2] pA;
        uint[2][2] pB;
        uint[2] pC;
        uint[1] pubSignals;
    }

    struct WithdrawParams {
        bytes32 root;
        bytes32 nullifierHash;
        uint8[4] receiptOrder;
        address payable[15][4] recipient;
        address payable relayer;
        uint256 amount;
        uint256 fee;
        uint256 refund;
    }

    /**
    @dev 构造函数
    @param _verifier1 验证器1的地址
    @param _verifier2 验证器2的地址
    @param _hasher MiMC哈希合约的地址
    @param _denominations 每个存款的转账金额
    @param _merkleTreeHeight 存款Merkle树的高度
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
    @dev 存款函数
    @param _userCommitment 用户的承诺值，PedersenHash(nullifier, secret)
    */
    function deposit(bytes32 _userCommitment) external payable nonReentrant {
        // 提取金额并转换为长度为4的uint8数组
        uint8[4] memory amountDigits = extractAmountAndConvertToDigits(
            _userCommitment
        );

        // 从digits数组还原出amount值
        uint256 amount = reconstructAmountFromDigits(amountDigits);

        require(
            amount > 0,
            "Amount extracted from commitment must be greater than 0"
        );
        _processDeposit(amount);

        emit Deposit(_userCommitment, block.timestamp);
    }

    /**
    @dev 聚合用户承诺
    @param proof zkSNARK证明数据
    @param _commitment 序列化器的承诺值，槽位根
    */
    function commit(
        Proof calldata proof,
        bytes32 _commitment
    ) external payable nonReentrant {
        require(!commitments[_commitment], "The commitment has been submitted");

        require(
            verifier2.verifyProof(
                proof.pA,
                proof.pB,
                proof.pC,
                proof.pubSignals
            ),
            "Invalid commit proof"
        );

        uint32 insertedIndex = _insert(_commitment);
        commitments[_commitment] = true;

        emit Commit(_commitment, insertedIndex, block.timestamp);
    }

    /** @dev 由子合约定义的存款处理函数 */
    function _processDeposit(uint256 _amount) internal virtual;

    /**
    @dev 提现函数
    @param proof zkSNARK证明数据
    @param params 提现参数，包括公共输入
    */
    function withdraw(
        Proof calldata proof,
        WithdrawParams calldata params
    ) external payable nonReentrant {
        for (uint8 i = 0; i < 4; i++) {
            require(
                params.fee <= denominations[i],
                "Fee exceeds transfer value"
            );
        }
        require(
            !nullifierHashes[params.nullifierHash],
            "The note has been already spent"
        );
        require(isKnownRoot(params.root), "Cannot find your merkle root");

        require(
            verifier2.verifyProof(
                proof.pA,
                proof.pB,
                proof.pC,
                proof.pubSignals
            ),
            "Invalid withdraw proof"
        );

        nullifierHashes[params.nullifierHash] = true;
        _processWithdraw(
            params.receiptOrder,
            params.recipient,
            params.relayer,
            params.amount,
            params.fee,
            params.refund
        );
        emit Withdrawal(params.nullifierHash, params.relayer, params.fee);
    }

    /** @dev 由子合约定义的提现处理函数 */
    function _processWithdraw(
        uint8[4] memory _receiptOrder,
        address payable[15][4] memory _recipient,
        address payable _relayer,
        uint256 _amount,
        uint256 _fee,
        uint256 _refund
    ) internal virtual;

    /** @dev 检查票据是否已花费 */
    function isSpent(bytes32 _nullifierHash) public view returns (bool) {
        return nullifierHashes[_nullifierHash];
    }

    /** @dev 检查一组票据是否已花费 */
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

    /** @dev 从数字数组计算金额 */
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

    /** @dev 从承诺值中提取金额并转换为数字数组 */
    function extractAmountAndConvertToDigits(
        bytes32 _commitment
    ) internal pure returns (uint8[4] memory digits) {
        uint256 amount = uint256(_commitment) & 0xFFFF; // 提取最后2个字节

        digits = [uint8(0), uint8(0), uint8(0), uint8(0)];

        if (amount == 0) {
            return digits;
        }

        // 将amount转换为十进制数字
        uint8[5] memory tempDigits;
        uint8 numDigits = 0;
        uint256 tempAmount = amount;

        while (tempAmount > 0) {
            tempDigits[numDigits] = uint8(tempAmount % 10);
            tempAmount = tempAmount / 10;
            numDigits++;
        }

        // 处理digits数组
        if (numDigits <= 4) {
            for (uint8 i = 0; i < numDigits; i++) {
                digits[3 - i] = tempDigits[i];
            }
        } else {
            digits[0] = uint8(
                tempDigits[numDigits - 1] * 10 + tempDigits[numDigits - 2]
            );
            digits[1] = tempDigits[numDigits - 3];
            digits[2] = tempDigits[numDigits - 4];
            digits[3] = tempDigits[numDigits - 5];
        }

        return digits;
    }
}
