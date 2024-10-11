const path = require("path");
const fs = require("fs"); // Import the fs module to handle file operations
const wasm_tester = require("circom_tester").wasm;
const {
    initialize,
    genC,
    buildSlot,
    genRandomSecret,
    calPedersen,
    updateEra,
    leBufferToBigInt,
    initEra
} = require('../src/utils.js');

describe("User prove secret in era test, with 60 receipts", function () {
    let circuit;

    this.timeout(100000);

    before(async () => {
        await initialize();
        circuit = await wasm_tester(path.join(__dirname, "circuits", "opt_withdraw_max.circom"));
    });

    it("Should calculate a correct era root", async () => {
        // User secret and transaction setup
        const [nullifierBuff, secretBuff] = genRandomSecret();
        const nullifierhash = calPedersen(nullifierBuff);

        const position = 3; // Transaction position in slot
        const receipt = 1134919853678403380976140193538799682604117182403n;
        const relayer = 0;
        const fee = 0;
        const refund = 0;

        // Slot setup
        const slotDepth = 5;
        // Generate a slot
        let slotLeaves = [];
        let i = 0;
        while (i < 2 ** slotDepth) {
            slotLeaves.push(genC());
            i++;
        }
        slotLeaves[position] = genC([nullifierBuff, secretBuff]); // User's transaction in slot
        const [slotRoot, slotIndexPath, slotElementPath] = buildSlot(slotDepth, slotLeaves, position);

        // Era setup
        const eraDepth = 20;
        const eraZero = 123;
        // Initialize an era and get the current paths
        const [eraIndexPath, eraElementPath] = initEra(eraDepth, eraZero);

        // Update era with a new commitment (slot root hash value) and get the new root hash value
        const eraNewRoot = updateEra(slotRoot, eraIndexPath, eraElementPath);

        const input = {
            l1root: eraNewRoot,
            nullifierHash: nullifierhash,
            r1: Array(15).fill(receipt),
            r2: Array(15).fill(receipt),
            r3: Array(15).fill(receipt),
            r4: Array(15).fill(receipt),
            relayer: relayer,
            fee: fee,
            refund: refund,
            nullifier: leBufferToBigInt(nullifierBuff),
            secret: leBufferToBigInt(secretBuff),
            l1pathElements: eraElementPath,
            l1pathIndices: eraIndexPath,
            l2root: slotRoot,
            l2pathElements: slotElementPath,
            l2pathIndices: slotIndexPath
        };

        // Save the input object to a JSON file at relative path "../circuit_input"
        const outputPath = path.join(__dirname, "../circuit_input/opt_withdraw_max.json");
        fs.writeFileSync(outputPath, JSON.stringify(input, null, 2));

        const w = await circuit.calculateWitness(input);

        const out2 = nullifierhash;
        await circuit.assertOut(w, { out: out2 });
        await circuit.checkConstraints(w);
    });

});