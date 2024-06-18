const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const crypto = require('crypto');

const buildMimcSponge = require("circomlibjs").buildMimcSponge;
const buildPedersenHash = require("circomlibjs").buildPedersenHash;
const buildBabyJub = require("circomlibjs").buildBabyjub;

let mimcSponge;
let F1;
let babyJub
let pedersen;
let F2;

function genRandomCommitment() {
    const nullifier = crypto.randomBytes(32);
    const secret = crypto.randomBytes(32);

    const h = pedersen.hash(Buffer.concat([nullifier, secret]));
    const hP = babyJub.unpackPoint(h);
    const c = F2.toObject(hP[0]);

    return c;
}

describe("relayer batch tx into slot test", function () {
    let circuit;

    this.timeout(100000);

    before(async () => {
        mimcSponge = await buildMimcSponge();
        F1 = mimcSponge.F;

        babyJub = await buildBabyJub();
        F2 = babyJub.F;
        pedersen = await buildPedersenHash();

        circuit = await wasm_tester(path.join(__dirname, "circuits", "batch.circom"));
    });

    it("Should calculate a correct slot root", async () => {

        const slotDepth = 5;

        const test_leaf = genRandomCommitment();
        const test_leaves = new Array(2 ** slotDepth).fill(test_leaf);

        const w = await circuit.calculateWitness({ l2leaf: test_leaves });

        let i = 0;
        let tmp = test_leaf;
        while (i < slotDepth) {
            tmp = F1.toObject(mimcSponge.multiHash([tmp, tmp], 0, 1));
            i++;
        }

        const out2 = tmp;
        await circuit.assertOut(w, { out: out2 });
        await circuit.checkConstraints(w);
    });

});
