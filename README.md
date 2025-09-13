# MerkleTree

A Swift implementation of a Merkle Tree that respects the Tree Hash EXchange format (THEX).

[![swift](https://github.com/swift-tree/MerkleTree/actions/workflows/swift.yml/badge.svg)](https://github.com/swift-tree/MerkleTree/actions/workflows/swift.yml)

## Overview

A Merkle Tree is a tree in which every leaf node is labelled with the hash of a data block, and every non-leaf node is labelled with the cryptographic hash of the labels of its child nodes. Merkle trees allow efficient and secure verification of the contents of large data structures.

This implementation follows the THEX format, which is designed for efficiently finding and transmitting differences between files.

### Balanced Trees
```
              ROOT=IH(E+F)
              /      \
             /        \
       E=IH(A+B)       F=IH(C+D)
       /     \           /    \
      /       \         /      \
A=LH(S1)  B=LH(S2) C=LH(S3)  D=LH(S4)
```

### Unbalanced Trees
```
                    ROOT=IH(H+E)
                     /        \
                    /          \
             H=IH(F+G)          E
             /       \           \
            /         \           \
      F=IH(A+B)       G=IH(C+D)     E
      /     \           /     \      \
     /       \         /       \      \
A=LH(S1)  B=LH(S2) C=LH(S3)  D=LH(S4) E=LH(S5)
```

## When to Use a Merkle Tree

Merkle Trees are particularly useful when you need to verify the integrity of a large set of data in an efficient and secure manner. Here are a few scenarios where Merkle Trees are a good choice:

*   **Verifying Data Integrity in Distributed Systems:** In a peer-to-peer network, where data is distributed across multiple nodes, Merkle Trees can be used to ensure that the data is consistent and has not been tampered with. For example, file-sharing applications like BitTorrent use Merkle Trees to verify the integrity of file pieces downloaded from different peers.

*   **Blockchain and Cryptocurrencies:** Merkle Trees are a fundamental component of blockchain technology. In Bitcoin, for example, a Merkle Tree is used to summarize all the transactions in a block, creating a single root hash that is included in the block's header. This allows for efficient verification of transactions without having to download the entire block.

*   **Certificate Transparency:** To ensure the integrity of SSL/TLS certificates, Google's Certificate Transparency project uses Merkle Trees to create a public log of all issued certificates. This allows anyone to verify that a certificate is valid and has not been tampered with.

*   **Verifiable Databases:** Merkle Trees can be used to create verifiable databases, where a user can query the database and receive a cryptographic proof that the returned data is correct and has not been tampered with.

In general, if you have a large amount of data and you need to provide a way for users to efficiently verify the integrity of that data, a Merkle Tree is a good data structure to consider.

## Features

-   Builds a Merkle Tree from an array of `Data` blobs.
-   Handles both balanced and unbalanced trees.
-   Generates audit trails (proofs) for a given item.
-   Verifies audit trails.
-   Follows the THEX format.

## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code. To use MerkleTree with SPM, add a dependency to your `Package.swift` file:

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/swift-tree/MerkleTree.git", from: "1.0.0")
    ]
)
```

## Usage

### Creating a Merkle Tree

To create a Merkle Tree, you can use the `build(fromBlobs:)` static method, which takes an array of `Data` blobs.

```swift
import MerkleTree
import Foundation

let dataBlobs = [
    "Hello".data(using: .utf8)!, 
    "World".data(using: .utf8)!, 
    "This".data(using: .utf8)!, 
    "is".data(using: .utf8)!, 
    "a".data(using: .utf8)!, 
    "Merkle".data(using: .utf8)!, 
    "Tree".data(using: .utf8)!, 
]

let merkleTree = MerkleTree.build(fromBlobs: dataBlobs)

// Get the root hash
let rootHash = merkleTree.value.hash
print("Root Hash: \(rootHash)")
```

### Creating and Verifying an Audit Trail

You can create an audit trail to prove that a specific data blob is part of the Merkle Tree.

```swift
// Create a leaves array to get the audit trail
var leaves = [MerkleTree]()
func getLeaves(tree: MerkleTree) {
    if tree.children.left == nil && tree.children.right == nil {
        leaves.append(tree)
    }
    if let left = tree.children.left {
        getLeaves(tree: left)
    }
    if let right = tree.children.right {
        getLeaves(tree: right)
    }
}
getLeaves(tree: merkleTree)

// Get the hash of the item you want to audit
let itemToAudit = "Hello".data(using: .utf8)!
let itemHash = itemToAudit.doubleHashedHex

// Get the audit trail
let auditTrail = merkleTree.getAuditTrail(for: itemHash, leaves: leaves)

// Verify the audit trail
let isValid = merkleTree.audit(itemHash: itemHash, auditTrail: auditTrail)
print("Audit trail is valid: \(isValid)") // true
```

## API

### `MerkleTree`

-   `build(fromBlobs: [Data]) -> MerkleTree`: Static method to build a Merkle Tree from an array of `Data` blobs.
-   `getAuditTrail(for itemHash: String, leaves: [MerkleTree]) -> [PathHash]`: Returns an audit trail for a given item hash.
-   `audit(itemHash: String, auditTrail: [PathHash]) -> Bool`: Verifies an audit trail for a given item hash.
-   `value: MerkleNode`: The node of the tree containing the hash.

### `MerkleNode`

-   `hash: String`: The hash of the node.

### `PathHash`

-   `hash: String`: The hash of the sibling node in the audit trail.
-   `leaf: Leaf`: The position of the sibling node (`.left` or `.right`).

## References

-   [https://en.wikipedia.org/wiki/Merkle_tree](https://en.wikipedia.org/wiki/Merkle_tree)
-   [https://adc.sourceforge.io/draft-jchapweske-thex-02.html](https://adc.sourceforge.io/draft-jchapweske-thex-02.html)
-   [https://github.com/quux00/merkle-tree](https://github.com/quux00/merkle-tree)

Erk Ekin
