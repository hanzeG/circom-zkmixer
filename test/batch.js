const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const {
    initialize,
    genC,
    buildSlot
} = require('../src/utils.js');

describe("Relayer batch tx into slot test", function () {
    let circuit;

    this.timeout(100000);

    before(async () => {
        await initialize();
        circuit = await wasm_tester(path.join(__dirname, "circuits", "batch.circom"));
    });

    it("Should calculate a correct slot root", async () => {

        // test case: slot depth is 5, 32 leave hash values
        const slotDepth = 5;
        const position = 3; // simulate the user commitment's position in slot

        // generate a slot
        let slotLeaves = [];
        let i = 0;
        while (i < 2 ** slotDepth) { slotLeaves.push(genC()); i++; }

        const w = await circuit.calculateWitness({ l2leaf: slotLeaves });

        const out2 = buildSlot(slotDepth, slotLeaves, position);

        await circuit.assertOut(w, { out: out2[0] });
        await circuit.checkConstraints(w);
    });

});
