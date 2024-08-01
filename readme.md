# An Implementation of a Cost-Effective Blockchain Privacy Protocol Based on ZK-SNARKs

This repository builds on [Tornado Cash (TC)](https://github.com/tornadocash/tornado-core.git) to provide a batch processing ZK Mixer solution. Users switch from individually making deposit operations on the blockchain's smart contracts to executing through sequencers. This process is similar to the ZK layer2 approach: (1) Sequencers record transaction information in a fully binary tree called *slot* while packaging each batch of transactions and generate the corresponding ZKP. (2) When generating the ZKP for withdrawal, users first need to prove that their commitment exists in the 'slot,' and then prove that the *slot* exists in the global state managed by the on-chain smart contract, similar to the incremental Merkle tree used by Tornado Cash to store global state, which we call *era*.

![Workflow in TC and in the protocol after adopting SNARKs for batch processing](readme/lifecircle.pdf)

## Installation

1. Clone the repo: `git clone https://github.com/hanzeG/circom-zkmixer.git`

2. Install pre-requisites: `npm i`

3. Download Circom: follow the instructions at [installing Circom](https://docs.circom.io/getting-started/installation/).

4. Download snarkjs: `npm install -g snarkjs`

![The left and right parts of the diagram respectively illustrate the interaction workflows among the main entities in the TC protocol and in our modified protocol. In the TC protocol workflow, using an incremental Merkle tree of depth 2 as an example, we demonstrate the main steps of completing a deposit at time $t0$-$t1$ and a withdraw at time $t3$. In the workflow of the modified protocol, using the same depth 2 incremental Merkle tree \emph{era} and a fully populated Merkle tree \emph{slot} as examples, we show the main steps of the sequencer completing a batch submission at time $t2$-$t3$, and the user performing a withdraw at the same time.](readme/reducing_cost.pdf)