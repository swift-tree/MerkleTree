import BinaryTree
import CryptoKit
import Foundation
import Tree

public typealias MerkleTree = BinaryTree<MerkleNode>

extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}

public extension Data {
  private var hashedHex: String { SHA256.hash(data: self).hexStr }
  var doubleHashedHex: String { SHA256.hash(data: Data(hashedHex.utf8)).hexStr }
}

public struct MerkleNode: Hashable {
  public let hash: String

  public init(blob: Data) { hash = blob.doubleHashedHex }
  public init(hash: String) { self.hash = hash }
}
