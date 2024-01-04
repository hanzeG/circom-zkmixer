const axios = require("axios");

async function getTransactionsPerSecond() {
    // Each block on Hedera is approximately 2 seconds.
    const numBlocks = 5;

    // Use the mirror node REST API to get info from the last 5 blocks.
    const blocksUrl = `https://mainnet-public.mirrornode.hedera.com/api/v1/blocks?limit=${numBlocks}`;
    const response = await axios.get(blocksUrl);

    // Add up the transactions from each block.
    const blocks = response.data["blocks"];
    const sumOfTransactions = blocks.reduce((acc, block) => acc + block["count"], 0);

    // Calculate the duration of the 5 blocks from the timestamps of the first and last blocks.
    const newestBlockToTimestamp = parseFloat(blocks[0]["timestamp"]["to"]);
    const oldestBlockFromTimestamp = parseFloat(blocks[numBlocks - 1]["timestamp"]["from"]); // Corrected index
    const duration = newestBlockToTimestamp - oldestBlockFromTimestamp;

    // Calculate the transactions per second.
    const transactionsPerSecond = sumOfTransactions / duration;
    return transactionsPerSecond;
}

(async () => {
    const TPS = await getTransactionsPerSecond();
    console.log(`Hedera TPS: ${TPS}`);
})();
