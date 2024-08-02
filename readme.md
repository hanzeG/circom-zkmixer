# Implementation of a Cost-Effective Blockchain Privacy Protocol Based on ZK-SNARKs

This repository builds on [Tornado Cash (*TC*)](https://github.com/tornadocash/tornado-core.git) to provide a batch processing ZK Mixer solution. Users switch from individually making deposit operations on the blockchain's smart contracts to executing through sequencers. This process is similar to the ZK layer2 approach: (1) Sequencers record transaction information in a fully binary tree called *slot* while packaging each batch of transactions and generate the corresponding ZKP. (2) When generating the ZKP for withdrawal, users first need to prove that their commitment exists in the *slot,' and then prove that the *slot* exists in the global state managed by the on-chain smart contract, similar to the incremental Merkle tree used by Tornado Cash to store global state, which we call *era*.

![Workflow in TC and in the protocol after adopting SNARKs for batch processing](figure/lifecircle.png)

In the above diagram, we compare our implementation with the *TC* process as a baseline. The workflow using batch processing is illustrated with one of the mixer pools, *S2*.

## Installation

1. Clone the repo: `git clone https://github.com/hanzeG/circom-zkmixer.git`

2. Install pre-requisites: `npm i`

3. Download Circom: follow the instructions at [installing Circom](https://docs.circom.io/getting-started/installation/).

4. Download snarkjs: `npm install -g snarkjs`

## Test Circuits

Run test case: `npm test`

- Circuit 1: Simulate the process of a sequencer packaging 32 transactions into a *slot.*'* The *slot*'* is a complete binary tree constructed using the MiMC Sponge hash function from [Circomlib](https://github.com/iden3/circomlib), with a depth of 5. The leaf nodes of the *slot*'* are commitments generated by the Pedersen hash function from each transaction's information. The left and right preimages of each commitment are defined by Tornado Cash as the *nullifier* and *secret*, respectively, and are simulated using a 32-byte random number generator.

- Circuit 2: Simulate the process of a user generating a ZKP for withdrawal. The user needs to: (1) First, compute the transaction commitment by hashing the nullifier and secret using the Pedersen hash function to prove their legitimate identity. (2) Then, prove that the transaction commitment exists in the *slot,* meaning the transaction has been included in a batch by the sequencer. (3) Finally, prove that the *slot* exists in the current global state *era*. In the test, we simulate the process where, after the sequencer first packages a set of transactions, the initiator of one transaction in this set generates the corresponding ZKP to attempt withdrawal.

## Workflow

In the diagram below, we provide a detailed comparison between our implementation and the main *TC* process. The key difference is that in our scheme, in addition to the original on-chain state storage Merkle tree from *TC*, which we call *era*, we also introduce an off-chain state storage Merkle tree for storing each batch of packaged transactions, which we call *slot*.

![Workflow Details](figure/reducing_cost.png)

The left and right parts of the diagram respectively illustrate the interaction workflows among the main entities in the *TC* protocol and in our modified protocol. In the *TC* protocol workflow, using an incremental Merkle tree of depth 2 as an example, we demonstrate the main steps of completing a deposit at time *t0*-*t1* and a withdraw at time *t3*. In the workflow of the modified protocol, using the same depth 2 incremental Merkle tree *era* and a fully populated Merkle tree *slot* as examples, we show the main steps of the sequencer completing a batch submission at time *t2*-*t3*, and the user performing a withdraw at the same time.