const {
    Client,
    PrivateKey,
    AccountCreateTransaction,
    AccountBalanceQuery,
    Hbar,
    TransferTransaction,
} = require("@hashgraph/sdk");
require("dotenv").config();

async function environmentSetup() {
    // Grab your Hedera testnet account ID and private key from your .env file
    const myAccountId = process.env.MY_ACCOUNT_ID;
    const myPrivateKey = process.env.MY_PRIVATE_KEY;

    // If we weren't able to grab it, we should throw a new error
    if (myAccountId == null || myPrivateKey == null) {
        throw new Error(
            "Environment variables myAccountId and myPrivateKey must be present"
        );
    }

    // Create your connection to the Hedera network
    const client = Client.forTestnet();

    //Set your account as the client's operator
    client.setOperator(myAccountId, myPrivateKey);

    // Set default max transaction fee & max query payment
    client.setMaxTransactionFee(new Hbar(100));
    client.setMaxQueryPayment(new Hbar(50));

    // Create new keys
    const newAccountPrivateKey = PrivateKey.generateED25519();
    const newAccountPublicKey = newAccountPrivateKey.publicKey;

    console.log("newAccountPrivateKey:");
    console.log(newAccountPrivateKey.toString());
    console.log("newAccountPublicKey:");
    console.log(newAccountPublicKey.toString());


    // Create a new account with 1,000 tinybar starting balance
    const newAccountTransactionResponse = await new AccountCreateTransaction()
        .setKey(newAccountPublicKey)
        .setInitialBalance(Hbar.fromTinybars(1000))
        .execute(client);

    // Get the new account ID
    const getReceipt = await newAccountTransactionResponse.getReceipt(client);
    const newAccountId = getReceipt.accountId;

    console.log("\nNew account ID: " + newAccountId);

    // Verify the account balance
    const accountBalance = await new AccountBalanceQuery()
        .setAccountId(newAccountId)
        .execute(client);

    console.log(
        "\nNew account balance is: " +
        accountBalance.hbars.toTinybars() +
        " tinybars."
    );

    // Create the transfer transaction
    const sendHbar = await new TransferTransaction()
        .addHbarTransfer(myAccountId, Hbar.fromTinybars(-1000))
        .addHbarTransfer(newAccountId, Hbar.fromTinybars(1000))
        .freezeWith(client);

    const signedTx = await sendHbar.sign(newAccountPrivateKey);

    console.log("The public keys that signed the transaction " + signedTx.getSignatures());

    const response = await signedTx.execute(client);


    console.log("TransferTransaction String:");
    console.log((response).toString());

    console.log("TransferTransaction JSON:");
    console.log((response).toJSON());

    // Verify the transaction reached consensus
    const transactionReceipt = await response.getReceipt(client);
    console.log(
        "\nThe transfer transaction from my account to the new account was: " +
        transactionReceipt.status.toString()
    );

    console.log("transactionReceipt:");
    console.log(transactionReceipt.toJSON());
}
environmentSetup();