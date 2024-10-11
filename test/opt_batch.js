const path = require("path");
const fs = require("fs"); // Include fs module for file operations
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
        circuit = await wasm_tester(path.join(__dirname, "circuits", "opt_batch.circom"));
    });

    it("Should calculate a correct slot root", async () => {

        // Test case: slot depth is 5, 32 leaf hash values
        const slotDepth = 5;
        const position = 3; // Simulate the user commitment's position in slot

        // Generate a slot
        let slotLeaves = [];
        let i = 0;
        while (i < 2 ** (slotDepth - 1)) {
            slotLeaves.push([genC(), genC()]);
            i++;
        }

        // Prepare the input object
        const input = { leaves: slotLeaves };

        // Save the input object to a JSON file at relative path "../circuit_input"
        const outputPath = path.join(__dirname, "../circuit_input/opt_batch.json");
        fs.writeFileSync(outputPath, JSON.stringify(input, null, 2));

        const w = await circuit.calculateWitness(input);

        const out2 = buildSlot(slotDepth, slotLeaves.flat(), position);

        await circuit.assertOut(w, { out: out2[0] });
        await circuit.checkConstraints(w);
    });

});