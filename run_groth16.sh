PROOF_SYS=(
    "groth16"
    # "plonk"
    # "fflonk"
)

CIRCUIT_NAMES=(
    "test/circuits/opt_withdraw_max"
    "test/circuits/opt_batch"
)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TARGET_DIR="$SCRIPT_DIR/.target"

for PROOF_SY in "${PROOF_SYS[@]}"
do
    for CIRCUIT_NAME in "${CIRCUIT_NAMES[@]}"
    do
        case $CIRCUIT_NAME in
            "test/circuits/opt_withdraw_max")
                PTAU_NAME="pot16_final"
                INPUT_NAME="opt_withdraw_max"
                ;;
            "test/circuits/opt_batch")
                PTAU_NAME="pot16_final"
                INPUT_NAME="opt_batch"
                ;;
            *)
                echo "Unknown CIRCUIT_NAME: $CIRCUIT_NAME"
                exit 1
                ;;
        esac

        CIRCUIT="$SCRIPT_DIR/$CIRCUIT_NAME.circom"
        PTAU="$SCRIPT_DIR/.ptau/$PTAU_NAME.ptau"
        INPUT="$SCRIPT_DIR/circuit_input/${INPUT_NAME}.json"

        GEN_DIR="$TARGET_DIR/${INPUT_NAME}_js"

        mkdir -p $TARGET_DIR

        echo ">> ---------- TEST CASE: $CIRCUIT_NAME in $PROOF_SY ----------"

        # ******************************************************
        # ************* Circuit **************
        # ******************************************************  
        echo ">> 1.1 Compiling Circuit"
        circom $CIRCUIT --r1cs --wasm --sym --c --wat --output "$TARGET_DIR"
        echo "-------------------------------------------------------"
        echo ">> 1.2 Generating Witness"
        node $GEN_DIR/generate_witness.js $GEN_DIR/$INPUT_NAME.wasm $INPUT $TARGET_DIR/witness.wtns
        echo "-------------------------------------------------------"
        echo ">> 1.3 View information about the circuit"
        snarkjs r1cs info $TARGET_DIR/$INPUT_NAME.r1cs
        echo "-------------------------------------------------------"
        # echo ">> 1.4 Print the constraints"
        # snarkjs r1cs print $TARGET_DIR/$INPUT_NAME.r1cs $TARGET_DIR/$INPUT_NAME.sym
        # echo "-------------------------------------------------------"

        # ******************************************************
        # ************* Setup **************
        # ******************************************************  
        echo ">> 2.1 Generating $PROOF_SY zkey"
        NODE_OPTIONS=--max-old-space-size=12000 /usr/bin/time -l snarkjs $PROOF_SY setup $TARGET_DIR/$INPUT_NAME.r1cs $PTAU $TARGET_DIR/$INPUT_NAME"_${PROOF_SY}_final.zkey"
        echo "-------------------------------------------------------"
        # echo ">> 2.2 First contribution to zkey"
        # NODE_OPTIONS=--max-old-space-size=12000 snarkjs zkey contribute $TARGET_DIR/$INPUT_NAME"_0000.zkey" $TARGET_DIR/$INPUT_NAME"_0001.zkey" --name="First Contribution to zkey" -v -e="GUO"
        # echo "-------------------------------------------------------"
        # echo ">> 2.3 Second contribution to zkey"
        # NODE_OPTIONS=--max-old-space-size=12000 snarkjs zkey contribute $TARGET_DIR/$INPUT_NAME"_0001.zkey" $TARGET_DIR/$INPUT_NAME"_0002.zkey" --name="Second Contribution to zkey" -v -e="HANZE"
        # echo "-------------------------------------------------------"
        # echo ">> 2.4 Apply a random beacon"
        # NODE_OPTIONS=--max-old-space-size=12000 snarkjs zkey beacon $TARGET_DIR/$INPUT_NAME"_0002.zkey" $TARGET_DIR/$INPUT_NAME"_${PROOF_SY}_final.zkey" 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"
        # echo "-------------------------------------------------------"
        echo ">> 2.5. Exporting Verification Key"
        NODE_OPTIONS=--max-old-space-size=12000 snarkjs zkey export verificationkey $TARGET_DIR/$INPUT_NAME"_${PROOF_SY}_final.zkey" $TARGET_DIR/${PROOF_SY}_verification_key.json
        echo "-------------------------------------------------------"

        # ******************************************************
        # ************* Prove **************
        # ****************************************************** 
        echo ">> 3.1 Generating proof by $PROOF_SY"
        NODE_OPTIONS=--max-old-space-size=12000 /usr/bin/time -l snarkjs $PROOF_SY prove $TARGET_DIR/$INPUT_NAME"_${PROOF_SY}_final.zkey" $TARGET_DIR/witness.wtns $TARGET_DIR/${PROOF_SY}_proof.json $TARGET_DIR/${PROOF_SY}_public.json
        echo "-------------------------------------------------------"
        echo ">> 3.2 Verifying proof"
        NODE_OPTIONS=--max-old-space-size=12000 /usr/bin/time -l snarkjs $PROOF_SY verify $TARGET_DIR/${PROOF_SY}_verification_key.json $TARGET_DIR/${PROOF_SY}_public.json $TARGET_DIR/${PROOF_SY}_proof.json
        echo "-------------------------------------------------------"

        # ******************************************************
        # ************* SC **************
        # ****************************************************** 
        echo ">> 4.1 Generating verifier by $PROOF_SY"
        snarkjs zkey export solidityverifier $TARGET_DIR/$INPUT_NAME"_${PROOF_SY}_final.zkey" ${INPUT_NAME}_verifier.sol
        echo "-------------------------------------------------------"

        echo ">> 4.2 Generating public input and proof by $PROOF_SY"
        snarkjs zkey export soliditycalldata $TARGET_DIR/${PROOF_SY}_public.json $TARGET_DIR/${PROOF_SY}_proof.json
    
    done
done