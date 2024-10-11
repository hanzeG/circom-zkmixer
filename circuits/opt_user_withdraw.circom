pragma circom 2.1.9;

include "utils.circom";

// Verifies that commitment that corresponds to given secret and nullifier is included in the merkle tree of deposits
template Withdraw(l1levels, l2levels, R1, R2, R3, R4) {
    signal input l1root;

    signal input nullifierHash;

    signal input r1[R1]; // not taking part in any computations
    signal input r2[R2]; // not taking part in any computations
    signal input r3[R3]; // not taking part in any computations
    signal input r4[R4]; // not taking part in any computations

    signal input relayer;  // not taking part in any computations
    signal input fee;      // not taking part in any computations
    signal input refund;   // not taking part in any computations
    signal input nullifier;
    signal input secret;

    signal input l1pathElements[l1levels];
    signal input l1pathIndices[l1levels];

    signal input l2root;
    signal input l2pathElements[l2levels];
    signal input l2pathIndices[l2levels];

    signal output out;

    // nullifier ==> nullifier hash
    component hasher = CommitmentHasher();
    hasher.nullifier <== nullifier;
    hasher.secret <== secret;
    hasher.nullifierHash === nullifierHash;

    // check l1 leaf existence
    component l1tree = MerkleTreeChecker(l1levels);
    l1tree.leaf <== l2root;
    l1tree.root <== l1root;
    for (var i = 0; i < l1levels; i++) {
        l1tree.pathElements[i] <== l1pathElements[i];
        l1tree.pathIndices[i] <== l1pathIndices[i];
    }

    // check l2 leaf existence
    component l2tree = MerkleTreeChecker(l2levels);
    l2tree.leaf <== hasher.commitment;
    l2tree.root <== l2root;
    for (var i = 0; i < l2levels; i++) {
        l2tree.pathElements[i] <== l2pathElements[i];
        l2tree.pathIndices[i] <== l2pathIndices[i];
    }

    // output
    out <== hasher.nullifierHash;

    // Add hidden signals to make sure that tampering with receipt or fee will invalidate the snark proof
    // Most likely it is not required, but it's better to stay on the safe side and it only takes 2 constraints
    // Squares are used to prevent optimizer from removing those constraints
    signal receipt1Square[R1];
    signal receipt2Square[R2];
    signal receipt3Square[R3];
    signal receipt4Square[R4];

    signal feeSquare;
    signal relayerSquare;
    signal refundSquare;
    
    // receiptSquare <== receipt * receipt;
    for (var i = 0; i < R1; i++) {
        receipt1Square[i] <== r1[i] * r1[i];
    }

    for (var i = 0; i < R2; i++) {
        receipt2Square[i] <== r2[i] * r2[i];
    }

    for (var i = 0; i < R3; i++) {
        receipt3Square[i] <== r3[i] * r3[i];
    }

    for (var i = 0; i < R4; i++) {
        receipt4Square[i] <== r4[i] * r4[i];
    }

    feeSquare <== fee * fee;
    relayerSquare <== relayer * relayer;
    refundSquare <== refund * refund;
}