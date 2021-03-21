import BinaryTree
import CryptoKit
import Foundation

private extension MerkleTree where Descendent == BinaryChildren<Element> {
  static func createParent(_ left: MerkleTree, _ right: MerkleTree) -> MerkleTree {
    guard let leftHash = left.value?.hash, let rightHash = right.value?.hash else { return .empty }
    return .node(value: .init(hash: Data((leftHash + rightHash).utf8).doubleHashedHex), .init(left, right))
  }
}

public extension MerkleTree where Descendent == BinaryChildren<Element> {
  init(hash: String) {
    self = .leaf(.init(hash: hash))
  }

  init(blob: Data) {
    self = .leaf(.init(blob: blob))
  }

  static func build(fromBlobs blobs: [Data]) -> Self {
    var nodeArray = blobs.map(MerkleTree.init(blob:))

    while nodeArray.count != 1 {
      var tmpArray = [MerkleTree]()

      while !nodeArray.isEmpty {
        let leftNode = nodeArray.removeFirst()
        let rightNode = !nodeArray.isEmpty ? nodeArray.removeFirst() : leftNode
        tmpArray.append(createParent(leftNode, rightNode))
      }

      nodeArray = tmpArray
    }

    return nodeArray.first!
  }
}
