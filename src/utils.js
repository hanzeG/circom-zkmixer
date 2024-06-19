const crypto = require('crypto');
const buildMimcSponge = require("circomlibjs").buildMimcSponge;
const buildPedersenHash = require("circomlibjs").buildPedersenHash;
const buildBabyJub = require("circomlibjs").buildBabyjub;

let mimcSponge;
let F1;
let babyJub;
let pedersen;
let F2;

async function initialize() {
    //initialize mimcsponge builder
    mimcSponge = await buildMimcSponge();
    F1 = mimcSponge.F;

    //initialize pedersen builder
    babyJub = await buildBabyJub();
    F2 = babyJub.F;
    pedersen = await buildPedersenHash();
}

function fromLittleEndianBinary(binaryArray) {
    let x = 0;
    for (let i = 0; i < binaryArray.length; i++) {
        x += binaryArray[i] * Math.pow(2, i);
    }
    return x;
}

function toLittleEndianBinary(x, y) {
    const binaryArray = new Array(y).fill(0);
    let i = 0;
    while (x > 0 && i < y) {
        binaryArray[i] = x % 2;
        x = Math.floor(x / 2);
        i++;
    }
    return binaryArray;
}


// generate a random nullifier and secret
function genRandomSecret() {
    let nullifier = crypto.randomBytes(31);
    let secret = crypto.randomBytes(31);
    return [nullifier, secret];
}

// generate a commitment with a nullifier and secret
function genC(secret) {
    if (!secret) {
        secret = genRandomSecret();
    }
    let c = calPedersen(Buffer.concat(secret));
    return c;
}

// calculate a mimc hash with left and right input
function calMimcHash(left, right) {
    return F1.toObject(mimcSponge.multiHash([left, right], 0, 1));
}

// calculate a pedersen hash with a preimage
function calPedersen(preimage) {
    let h = pedersen.hash(preimage);
    let hP = babyJub.unpackPoint(h);
    return F2.toObject(hP[0]);
}

// initialize an era (incremental merkle tree) with depth and init value, return initial element path and index path
function initEra(depth, zero) {
    let i = 0;
    let tmp = zero;
    let elementPath = new Array(depth).fill(0);
    let indexPath = new Array(depth).fill(0);
    while (i < depth) {
        elementPath[i] = tmp;
        tmp = calMimcHash(tmp, tmp);
        i++;
    }
    return [indexPath, elementPath];
}

// build a slot merkle tree with depth, leave hash values and position, return root hash value, index path and element path
function buildSlot(depth, leaves, position) {
    let indexPath = toLittleEndianBinary(position, depth);
    let indexElement = calPath(indexPath);
    let elementPath = [];

    // helper function to recursively build the tree and compute the root hash
    function buildTree(currentDepth, nodes) {
        // if we reach the root (depth 0), return the only remaining node
        if (currentDepth === 0) {
            return [nodes[0], indexPath, elementPath];
        }

        // initialize a array for the parent level nodes
        let parentNodes = [];

        // iterate over pairs of nodes to compute their parent hashes
        for (let i = 0; i < nodes.length; i += 2) {
            let left = nodes[i];
            let right = nodes[i + 1];
            let parentHash = calMimcHash(left, right);
            parentNodes.push(parentHash);
        }
        elementPath.push(nodes[indexElement[depth - currentDepth]]);

        // recursively build the next level of the tree
        return buildTree(currentDepth - 1, parentNodes);
    }

    // start building the tree from the leaves with the given depth
    return buildTree(depth, leaves);
}

// update era with a new commitment with its index path and element path, 
// return the new era root hash value (and index path and element path for next)
function updateEra(c, indexPath, elementPath) {
    let i = 0;
    let tmp = c;
    while (i < indexPath.length) {
        if (indexPath[i] == 0) {
            tmp = calMimcHash(tmp, elementPath[i]);
        } else {
            tmp = calMimcHash(elementPath[i], tmp);
        }
        i++;
    };
    let root = tmp;
    return root;
}

// calculate the indexes of element path with a given index path, return an array
function calPath(index) {
    let x = fromLittleEndianBinary(index);
    let p = [];
    for (let i = 0; i < index.length; i++) {
        if (x % 2 === 0) { // x is even
            p.push(x + 1);
            x = x / 2;
        } else { // x is odd
            p.push(x - 1);
            x = (x - 1) / 2;
        }
    }
    return p;
}

function leBufferToBigInt(buffer) {
    if (buffer.byteLength !== 31) {
        throw new Error("Buffer length must be 31 bytes");
    }

    let hexString = '';
    const uint8Array = new Uint8Array(buffer);

    for (let i = uint8Array.length - 1; i >= 0; i--) {
        hexString += uint8Array[i].toString(16).padStart(2, '0');
    }

    return BigInt('0x' + hexString);
}

function bigIntToLeBuffer(bigInt) {
    const buffer = Buffer.alloc(31);

    let hexString = bigInt.toString(16);
    if (hexString.length % 2 !== 0) {
        hexString = '0' + hexString;
    }

    let byteIndex = 0;
    for (let i = hexString.length; i > 0; i -= 2) {
        buffer[byteIndex] = parseInt(hexString.slice(i - 2, i), 16);
        byteIndex++;
    }

    return buffer;
}


module.exports = {
    initialize,
    genC,
    calMimcHash,
    calPedersen,
    buildSlot,
    genRandomSecret,
    updateEra,
    leBufferToBigInt,
    bigIntToLeBuffer,
    initEra
};
