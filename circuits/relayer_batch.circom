pragma circom 2.1.9;

include "utils.circom";

// (5, 32)
template slotBuilder() {
    signal input l2leaf[32];
    signal output out;

    var l2leaf_4[16];
    var l2leaf_3[8];
    var l2leaf_2[4];
    var l2leaf_1[2];
    var l2leaf_0[1];

    component hashers[31];
    
    hashers[0] = HashLeftRight();
    hashers[0].left <== l2leaf[0];
    hashers[0].right <== l2leaf[1];
    l2leaf_4[0] = hashers[0].hash;

    hashers[1] = HashLeftRight();
    hashers[1].left <== l2leaf[2];
    hashers[1].right <== l2leaf[3];
    l2leaf_4[1] = hashers[1].hash;

    hashers[2] = HashLeftRight();
    hashers[2].left <== l2leaf[4];
    hashers[2].right <== l2leaf[5];
    l2leaf_4[2] = hashers[2].hash;

    hashers[3] = HashLeftRight();
    hashers[3].left <== l2leaf[6];
    hashers[3].right <== l2leaf[7];
    l2leaf_4[3] = hashers[3].hash;

    hashers[4] = HashLeftRight();
    hashers[4].left <== l2leaf[8];
    hashers[4].right <== l2leaf[9];
    l2leaf_4[4] = hashers[4].hash;

    hashers[5] = HashLeftRight();
    hashers[5].left <== l2leaf[10];
    hashers[5].right <== l2leaf[11];
    l2leaf_4[5] = hashers[5].hash;

    hashers[6] = HashLeftRight();
    hashers[6].left <== l2leaf[12];
    hashers[6].right <== l2leaf[13];
    l2leaf_4[6] = hashers[6].hash;

    hashers[7] = HashLeftRight();
    hashers[7].left <== l2leaf[14];
    hashers[7].right <== l2leaf[15];
    l2leaf_4[7] = hashers[7].hash;

    hashers[8] = HashLeftRight();
    hashers[8].left <== l2leaf[16];
    hashers[8].right <== l2leaf[17];
    l2leaf_4[8] = hashers[8].hash;

    hashers[9] = HashLeftRight();
    hashers[9].left <== l2leaf[18];
    hashers[9].right <== l2leaf[19];
    l2leaf_4[9] = hashers[9].hash;

    hashers[10] = HashLeftRight();
    hashers[10].left <== l2leaf[20];
    hashers[10].right <== l2leaf[21];
    l2leaf_4[10] = hashers[10].hash;

    hashers[11] = HashLeftRight();
    hashers[11].left <== l2leaf[22];
    hashers[11].right <== l2leaf[23];
    l2leaf_4[11] = hashers[11].hash;

    hashers[12] = HashLeftRight();
    hashers[12].left <== l2leaf[24];
    hashers[12].right <== l2leaf[25];
    l2leaf_4[12] = hashers[12].hash;

    hashers[13] = HashLeftRight();
    hashers[13].left <== l2leaf[26];
    hashers[13].right <== l2leaf[27];
    l2leaf_4[13] = hashers[13].hash;

    hashers[14] = HashLeftRight();
    hashers[14].left <== l2leaf[28];
    hashers[14].right <== l2leaf[29];
    l2leaf_4[14] = hashers[14].hash;

    hashers[15] = HashLeftRight();
    hashers[15].left <== l2leaf[30];
    hashers[15].right <== l2leaf[31];
    l2leaf_4[15] = hashers[15].hash;

    //
    hashers[16] = HashLeftRight();
    hashers[16].left <== l2leaf_4[0];
    hashers[16].right <== l2leaf_4[1];
    l2leaf_3[0] = hashers[16].hash;

    hashers[17] = HashLeftRight();
    hashers[17].left <== l2leaf_4[2];
    hashers[17].right <== l2leaf_4[3];
    l2leaf_3[1] = hashers[17].hash;

    hashers[18] = HashLeftRight();
    hashers[18].left <== l2leaf_4[4];
    hashers[18].right <== l2leaf_4[5];
    l2leaf_3[2] = hashers[18].hash;

    hashers[19] = HashLeftRight();
    hashers[19].left <== l2leaf_4[6];
    hashers[19].right <== l2leaf_4[7];
    l2leaf_3[3] = hashers[19].hash;

    hashers[20] = HashLeftRight();
    hashers[20].left <== l2leaf_4[8];
    hashers[20].right <== l2leaf_4[9];
    l2leaf_3[4] = hashers[20].hash;

    hashers[21] = HashLeftRight();
    hashers[21].left <== l2leaf_4[10];
    hashers[21].right <== l2leaf_4[11];
    l2leaf_3[5] = hashers[21].hash;

    hashers[22] = HashLeftRight();
    hashers[22].left <== l2leaf_4[12];
    hashers[22].right <== l2leaf_4[13];
    l2leaf_3[6] = hashers[22].hash;

    hashers[23] = HashLeftRight();
    hashers[23].left <== l2leaf_4[14];
    hashers[23].right <== l2leaf_4[15];
    l2leaf_3[7] = hashers[23].hash;

    //
    hashers[24] = HashLeftRight();
    hashers[24].left <== l2leaf_3[0];
    hashers[24].right <== l2leaf_3[1];
    l2leaf_2[0] = hashers[24].hash;

    hashers[25] = HashLeftRight();
    hashers[25].left <== l2leaf_3[2];
    hashers[25].right <== l2leaf_3[3];
    l2leaf_2[1] = hashers[25].hash;

    hashers[26] = HashLeftRight();
    hashers[26].left <== l2leaf_3[4];
    hashers[26].right <== l2leaf_3[5];
    l2leaf_2[2] = hashers[26].hash;

    hashers[27] = HashLeftRight();
    hashers[27].left <== l2leaf_3[6];
    hashers[27].right <== l2leaf_3[7];
    l2leaf_2[3] = hashers[27].hash;

    //
    hashers[28] = HashLeftRight();
    hashers[28].left <== l2leaf_2[0];
    hashers[28].right <== l2leaf_2[1];
    l2leaf_1[0] = hashers[28].hash;

    hashers[29] = HashLeftRight();
    hashers[29].left <== l2leaf_2[2];
    hashers[29].right <== l2leaf_2[3];
    l2leaf_1[1] = hashers[29].hash;

    //

    hashers[30] = HashLeftRight();
    hashers[30].left <== l2leaf_1[0];
    hashers[30].right <== l2leaf_1[1];
    l2leaf_0[0] = hashers[30].hash;

    out <== l2leaf_0[0];
}