#!/bin/bash
# The idea/ code is taken from the following links:
# https://github.com/0xPARC/circom-ecdsa
# https://www.guru99.com/introduction-to-shell-scripting.html
echo "-------------------------------------------------------"
CIRCUIT_NAME=XRPL_verify
INPUT_JSON=input.json
PTAU_NAME=pot22
echo "-------------------------------------------------------"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TARGET_DIR="$SCRIPT_DIR/circuit"
GEN_DIR="$SCRIPT_DIR/circuit/XRPL_verify_js"
mkdir -p $TARGET_DIR
time_sum=0
# echo "-------------------------------------------------------"
# echo ">>(Activity Monitor start:A ...)"
# python3 Rep1/task_3/plonk_Activity_Monitor_Graph.py &
# sleep 2
# echo ">>(Activity Monitor start:B ...)"
# sleep 3
# ******************************************************
# ************* Tau-Phase1 **************
# ******************************************************  
# echo "-------------------------------------------------------"
# echo ">> 1. Start a new powers of tau ceremony"
# start=`date +%s`
# snarkjs powersoftau new bn128 12 $TARGET_DIR/$PTAU_NAME"_0000.ptau" -v
# end=$(gdate +%s.%3N)
# time_diff=$(echo "$end - $start" | bc) 
# time_sum=$(echo "$time_sum + $time_diff" | bc) 
# formatted_time=$(printf "%.3f" $time_diff)
# echo ">>Step Completed:"
# echo "Time:($formatted_time s)"
# echo "-------------------------------------------------------"
# echo ">> 2. Contribute to the ceremony"
# start=`date +%s`
# npx snarkjs powersoftau contribute $TARGET_DIR/$PTAU_NAME"_0000.ptau" $TARGET_DIR/$PTAU_NAME"_0001.ptau" --name="First contribution" -v -e="GUO"
# end=$(gdate +%s.%3N)
# time_diff=$(echo "$end - $start" | bc) 
# time_sum=$(echo "$time_sum + $time_diff" | bc) 
# formatted_time=$(printf "%.3f" $time_diff)
# echo ">>Step Completed:"
# echo "Time:($formatted_time s)"
# echo "-------------------------------------------------------"
# echo ">> 3. Provide a second contribution"
# start=`date +%s`
# npx snarkjs powersoftau contribute $TARGET_DIR/$PTAU_NAME"_0001.ptau" $TARGET_DIR/$PTAU_NAME"_0002.ptau" --name="Second contribution" -v -e="HANZE"
# end=$(gdate +%s.%3N)
# time_diff=$(echo "$end - $start" | bc) 
# time_sum=$(echo "$time_sum + $time_diff" | bc) 
# formatted_time=$(printf "%.3f" $time_diff)
# echo ">>Step Completed:"
# echo "Time:($formatted_time s)"
# echo "-------------------------------------------------------"
# echo ">> 4. Verify the protocol so far"
# start=`date +%s`
# npx snarkjs powersoftau verify $TARGET_DIR/$PTAU_NAME"_0002.ptau"
# end=$(gdate +%s.%3N)
# time_diff=$(echo "$end - $start" | bc) 
# time_sum=$(echo "$time_sum + $time_diff" | bc) 
# formatted_time=$(printf "%.3f" $time_diff)
# echo ">>Step Completed:"
# echo "Time:($formatted_time s)"
# echo "-------------------------------------------------------"
# echo ">> 5. Apply a random beacon"
# start=`date +%s`
# npx snarkjs powersoftau beacon $TARGET_DIR/$PTAU_NAME"_0002.ptau" $TARGET_DIR/$PTAU_NAME"_beacon.ptau" 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"
# end=$(gdate +%s.%3N)
# time_diff=$(echo "$end - $start" | bc) 
# time_sum=$(echo "$time_sum + $time_diff" | bc) 
# formatted_time=$(printf "%.3f" $time_diff)
# echo ">>Step Completed:"
# echo "Time:($formatted_time s)"

# ******************************************************
# ************* Tau-Phase2 **************
# ******************************************************
# echo "-------------------------------------------------------"  
# echo ">> 6. Preparing Tau Phase 2"
# start=`date +%s`
# snarkjs powersoftau prepare phase2 $TARGET_DIR/$PTAU_NAME"_beacon.ptau" $TARGET_DIR/$PTAU_NAME"_final.ptau" -v
# end=$(gdate +%s.%3N)
# time_diff=$(echo "$end - $start" | bc) 
# time_sum=$(echo "$time_sum + $time_diff" | bc) 
# formatted_time=$(printf "%.3f" $time_diff)
# echo ">>Step Completed:"
# echo "Time:($formatted_time s)"
# echo "-------------------------------------------------------"  
# echo ">> 1.1. Verify the final ptau"
# start=`date +%s`
# snarkjs powersoftau verify $TARGET_DIR/$PTAU_NAME"_pre_final.ptau"
# end=$(gdate +%s.%3N)
# time_diff=$(echo "$end - $start" | bc) 
# time_sum=$(echo "$time_sum + $time_diff" | bc) 
# formatted_time=$(printf "%.3f" $time_diff)
# echo ">>Step Completed:"w
# echo "Time:($formatted_time s)"

# ******************************************************
# ************* Circuit **************
# ******************************************************  
echo ">> 2.1. Compiling Circuit"
start=`date +%s`
circom /Users/guohanze/Documents/zkp-solutions/zkp/ed25519-circom/test/circuits/XRPL_verify.circom --r1cs --wasm --sym --c --wat --output "$TARGET_DIR"
end=$(gdate +%s.%3N)
time_diff=$(echo "$end - $start" | bc) 
time_sum=$(echo "$time_sum + $time_diff" | bc) 
formatted_time=$(printf "%.3f" $time_diff)
echo ">>Step Completed:"
echo "Time:($formatted_time s)"
# echo "-------------------------------------------------------"
# echo ">> 2.2. Moving Files"
# start=`date +%s`
# mv $TARGET_DIR/verify_js/* $TARGET_DIR
# end=$(gdate +%s.%3N)
# time_diff=$(echo "$end - $start" | bc) 
# time_sum=$(echo "$time_sum + $time_diff" | bc) 
# formatted_time=$(printf "%.3f" $time_diff)
# echo ">>Step Completed:"
# echo "Time:($formatted_time s)"
# echo "-------------------------------------------------------"
# echo ">> 2.3. Exporting R1CS To JSON"
# start=`date +%s`
# snarkjs r1cs export json $TARGET_DIR/$CIRCUIT_NAME.r1cs $TARGET_DIR/$CIRCUIT_NAME.json
# end=$(gdate +%s.%3N)
# time_diff=$(echo "$end - $start" | bc) 
# time_sum=$(echo "$time_sum + $time_diff" | bc) 
# formatted_time=$(printf "%.3f" $time_diff)
# echo ">>Step Completed:"
# echo "Time:($formatted_time s)"
echo "-------------------------------------------------------"
echo ">> 2.4. Generating Witness"
start=`date +%s`
node $GEN_DIR/generate_witness.js $GEN_DIR/$CIRCUIT_NAME.wasm $SCRIPT_DIR/$INPUT_JSON $TARGET_DIR/witness.wtns
end=$(gdate +%s.%3N)
time_diff=$(echo "$end - $start" | bc) 
time_sum=$(echo "$time_sum + $time_diff" | bc) 
formatted_time=$(printf "%.3f" $time_diff)
echo ">>Step Completed:"
echo "Time:($formatted_time s)"

echo "-------------------------------------------------------"
echo ">> 2.5. Checking Witness"
start=`date +%s`
snarkjs wtns check $TARGET_DIR/$CIRCUIT_NAME.r1cs $TARGET_DIR/witness.wtns
end=$(gdate +%s.%3N)
time_diff=$(echo "$end - $start" | bc) 
time_sum=$(echo "$time_sum + $time_diff" | bc) 
formatted_time=$(printf "%.3f" $time_diff)
echo ">>Step Completed:"
echo "Time:($formatted_time s)"
# echo "-------------------------------------------------------"
# echo ">> 2.5. Exporting Witness To JSON"
# start=`date +%s`
# snarkjs wtns export json $TARGET_DIR/witness.wtns $TARGET_DIR/witness.json
# end=$(gdate +%s.%3N)
# time_diff=$(echo "$end - $start" | bc) 
# time_sum=$(echo "$time_sum + $time_diff" | bc) 
# formatted_time=$(printf "%.3f" $time_diff)
# echo ">>Step Completed:"
# echo "Time:($formatted_time s)"

# ******************************************************
# ************* Setup **************
# ******************************************************  
echo "-------------------------------------------------------"
echo ">> 1. Generating Groth16 zkey"
start=$(gdate +%s.%3N)
NODE_OPTIONS=--max-old-space-size=8000 snarkjs groth16 setup $TARGET_DIR/$CIRCUIT_NAME.r1cs /Users/guohanze/Documents/zkp-solutions/ed25519-circom/pot22_final.ptau $TARGET_DIR/$CIRCUIT_NAME"_0000.zkey"
end=$(gdate +%s.%3N)
time_diff=$(echo "$end - $start" | bc)
time_sum=$(echo "$time_sum + $time_diff" | bc)
formatted_time=$(printf "%.3f" $time_diff)
echo ">> Step Completed:"
echo "Time:($formatted_time s)"
echo "-------------------------------------------------------"
echo ">> 2. First contribution to zkey"
start=$(gdate +%s.%3N)
npx snarkjs zkey contribute $TARGET_DIR/$CIRCUIT_NAME"_0000.zkey" $TARGET_DIR/$CIRCUIT_NAME"_0001.zkey" --name="First Contribution to zkey" -v -e="GUO"
end=$(gdate +%s.%3N)
time_diff=$(echo "$end - $start" | bc)
time_sum=$(echo "$time_sum + $time_diff" | bc)
formatted_time=$(printf "%.3f" $time_diff)
echo ">> Step Completed:"
echo "Time:($formatted_time s)"
echo "-------------------------------------------------------"
echo ">> 3. Second contribution to zkey"
start=$(gdate +%s.%3N)
npx snarkjs zkey contribute $TARGET_DIR/$CIRCUIT_NAME"_0001.zkey" $TARGET_DIR/$CIRCUIT_NAME"_0002.zkey" --name="Second Contribution to zkey" -v -e="HANZE"
end=$(gdate +%s.%3N)
time_diff=$(echo "$end - $start" | bc)
time_sum=$(echo "$time_sum + $time_diff" | bc)
formatted_time=$(printf "%.3f" $time_diff)
echo ">> Step Completed:"
echo "Time:($formatted_time s)"
# echo "-------------------------------------------------------"
# echo ">> 4. Verify the latest zkey"
# start=$(gdate +%s.%3N)
# snarkjs zkey verify $TARGET_DIR/$CIRCUIT_NAME.r1cs /Users/guohanze/Documents/zkp-solutions/zkp_hsc/tau/pot22_final.pta.ptau $TARGET_DIR/$CIRCUIT_NAME"_0002.zkey"
# end=$(gdate +%s.%3N)
# time_diff=$(echo "$end - $start" | bc)
# time_sum=$(echo "$time_sum + $time_diff" | bc)
# formatted_time=$(printf "%.3f" $time_diff)
# echo ">> Step Completed:"
# echo "Time:($formatted_time s)"
echo "-------------------------------------------------------"
echo ">> 5. Apply a random beacon"
start=$(gdate +%s.%3N)
snarkjs zkey beacon $TARGET_DIR/$CIRCUIT_NAME"_0002.zkey" $TARGET_DIR/$CIRCUIT_NAME"_groth16_final.zkey" 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"
end=$(gdate +%s.%3N)
time_diff=$(echo "$end - $start" | bc)
time_sum=$(echo "$time_sum + $time_diff" | bc)
formatted_time=$(printf "%.3f" $time_diff)
echo ">> Step Completed:"
echo "Time:($formatted_time s)"
echo "-------------------------------------------------------"
echo ">> 6. Verify the final zkey"
start=$(gdate +%s.%3N)
NODE_OPTIONS=--max-old-space-size=8000 snarkjs zkey verify $TARGET_DIR/$CIRCUIT_NAME.r1cs /Users/guohanze/Documents/zkp-solutions/zkp/.ptau/pot22_final.ptau $TARGET_DIR/$CIRCUIT_NAME"_groth16_final.zkey"
end=$(gdate +%s.%3N)
time_diff=$(echo "$end - $start" | bc)
time_sum=$(echo "$time_sum + $time_diff" | bc)
formatted_time=$(printf "%.3f" $time_diff)
echo ">> Step Completed:"
echo "Time:($formatted_time s)"
echo "-------------------------------------------------------"
echo ">> 7. Exporting Verification Key"
start=$(gdate +%s.%3N)
snarkjs zkey export verificationkey $TARGET_DIR/$CIRCUIT_NAME"_groth16_final.zkey" $TARGET_DIR/groth16_verification_key.json
end=$(gdate +%s.%3N)
time_diff=$(echo "$end - $start" | bc)
time_sum=$(echo "$time_sum + $time_diff" | bc)
formatted_time=$(printf "%.3f" $time_diff)
echo ">> Step Completed:"
echo "Time:($formatted_time s)"

# ******************************************************
# ************* Prove **************
# ****************************************************** 
echo "-------------------------------------------------------"
echo ">> 1. Generating proof by groth16"
start=$(gdate +%s.%3N)
snarkjs groth16 prove $TARGET_DIR/$CIRCUIT_NAME"_groth16_final.zkey" $TARGET_DIR/witness.wtns $TARGET_DIR/groth16_proof.json $TARGET_DIR/groth16_public.json
end=$(gdate +%s.%3N)
time_diff=$(echo "$end - $start" | bc)
time_sum=$(echo "$time_sum + $time_diff" | bc)
formatted_time=$(printf "%.3f" $time_diff)
echo ">> Step Completed:"
echo "Time:($formatted_time s)"
echo "-------------------------------------------------------"
echo ">> 2. Verifying proof"
start=$(gdate +%s.%3N)
snarkjs groth16 verify $TARGET_DIR/groth16_verification_key.json $TARGET_DIR/groth16_public.json $TARGET_DIR/groth16_proof.json
end=$(gdate +%s.%3N)
time_diff=$(echo "$end - $start" | bc)
time_sum=$(echo "$time_sum + $time_diff" | bc)
formatted_time=$(printf "%.3f" $time_diff)
echo ">> Step Completed:"
echo "Time:($formatted_time s)"
echo "-------------------------------------------------------"
echo ">>Total Time Taken: $time_sum s"