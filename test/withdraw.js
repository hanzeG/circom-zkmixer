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

function initEra(depth, zero) {
    let i = 0;
    let tmp = zero;
    let zeros = new Array(depth).fill(zero);
    while (i < depth) {
        zeros[i] = tmp;
        tmp = F1.toObject(mimcSponge.multiHash([tmp, tmp], 0, 1));
        i++;
    }
    return zeros;
}

describe("user prove secret in era test", function () {
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

    it("Should calculate a correct era root", async () => {

        const slotDepth = 5;
        const eraDepth = 20;
        const zero = 21663839004416932945382355908790599225266501822907911457504978515578255421292n;
        const era = initEra(eraDepth, zero);

        const test_leaf = genRandomCommitment();
        const test_leaves = new Array(2 ** slotDepth).fill(test_leaf);

        const w = await circuit.calculateWitness({ l2leaf: test_leaves });


        const out2 = tmp;
        await circuit.assertOut(w, { out: out2 });
        await circuit.checkConstraints(w);
    });

});
