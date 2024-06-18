pragma circom 2.1.9;

include "utils.circom";

// Verifies that commitment that corresponds to given secret and nullifier is included in the merkle tree of deposits
template Withdraw(l1levels, l2levels) {
    signal input l1root;

    signal input nullifierHash;
    signal input recipient; // not taking part in any computations
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

    signal output valid;

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
    valid <== l1root;

    // Add hidden signals to make sure that tampering with recipient or fee will invalidate the snark proof
    // Most likely it is not required, but it's better to stay on the safe side and it only takes 2 constraints
    // Squares are used to prevent optimizer from removing those constraints
    signal recipientSquare;
    signal feeSquare;
    signal relayerSquare;
    signal refundSquare;
    recipientSquare <== recipient * recipient;
    feeSquare <== fee * fee;
    relayerSquare <== relayer * relayer;
    refundSquare <== refund * refund;
}