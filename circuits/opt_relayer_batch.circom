pragma circom 2.1.9;

include "utils.circom";

template slotBuilder(d) {
    var leavesNhalf = 2 ** (d - 1);
    var hasherN = 2 ** d - 1;

    signal input leaves[leavesNhalf][2];
    signal output out;

    component hasher[hasherN];
    
    var hashes[hasherN];

    for (var i = 0; i < hasherN; i++){
        hasher[i] = HashLeftRight();
        if (i < leavesNhalf) {
            hasher[i].left <== leaves[i][0];
            hasher[i].right <== leaves[i][1];
        } else {
            hasher[i].left <== hashes[(i - leavesNhalf) * 2];
            hasher[i].right <== hashes[(i - leavesNhalf) * 2 + 1];
        }

        hashes[i] = hasher[i].hash;
    }

    out <== hashes[hasherN - 1];
}