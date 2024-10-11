// generatePedersenHash.ts

import { pedersen_from_hex } from "pedersen-fast";
import * as crypto from "crypto";

// Function to generate a random hex string with a "0x" prefix
function getRandomHex(bytes: number): string {
    return '0x' + crypto.randomBytes(bytes).toString('hex');
}

// Desired checksum value (16-bit)
// Modify this value based on your specific checksum requirements
const DESIRED_CHECKSUM = 0x0001; // Example value

// Function to generate Pedersen hash with the desired checksum
function generatePedersenHashWithChecksum() {
    let attempts = 0;
    const startTime = Date.now(); // Record the start time

    while (true) {
        attempts++;

        // Generate two random 31-byte hexadecimal strings
        const nullifier = getRandomHex(31); // 31 bytes
        const secret = getRandomHex(31);     // 31 bytes

        try {
            // Compute Pedersen hash using the two hex strings
            const hashHex = pedersen_from_hex(nullifier, secret); // Returns a "0x" prefixed hex string

            // Convert the hash hex string to a Buffer (ensure fixed length by padding with leading zeros)
            const hashHexWithoutPrefix = hashHex.slice(2); // Remove "0x" prefix

            // Pad the hash to 64 hex characters (32 bytes) with leading zeros
            const fixedLengthHashHex = hashHexWithoutPrefix.padStart(64, '0');

            // Convert the hash hex string to a Buffer (remove "0x" prefix)
            const hashBuffer = Buffer.from(fixedLengthHashHex, 'hex'); // 32 bytes

            // Extract the last two bytes (16 bits) of the hash
            const lastTwoBytes = hashBuffer.slice(-2); // Buffer of length 2

            // Convert the last two bytes to a 16-bit integer (big-endian)
            const checksum = lastTwoBytes.readUInt16BE(0); // Example: 0x0001

            // Check if the checksum matches the desired value
            if (checksum === DESIRED_CHECKSUM) {
                const endTime = Date.now(); // Record the end time
                const timeTaken = (endTime - startTime) / 1000; // Time taken in seconds

                console.log(`\n✅ Found a matching hash after ${attempts} attempts.`);
                console.log(`Nullifier: ${nullifier}`);
                console.log(`Secret:     ${secret}`);
                console.log(`Hash:       ${hashHex}`);
                console.log(`Time Taken: ${timeTaken} seconds\n`);
                break;
            }

            // Every 10,000 attempts, log the progress
            if (attempts % 10000 === 0) {
                console.log(`🔄 Attempts: ${attempts}`);
            }
        } catch (error) {
            console.error(`⚠️ Error computing Pedersen hash:`, error);
        }
    }
}

// Execute the main function
generatePedersenHashWithChecksum();