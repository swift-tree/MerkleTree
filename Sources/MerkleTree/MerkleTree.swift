import CryptoKit
import Foundation

public typealias MerkleTree = TwoWayBinaryTree<MerkleNode>

public extension MerkleTree {
  convenience init(hash: String) {
    self.init(MerkleNode(hash: hash))
  }

  convenience init(blob: Data) {
    self.init(MerkleNode(blob: blob))
  }

  var height: Int {
    var sum = 1
    var rootChildren: TwoWayBinaryTree? = children.left
    while let left = rootChildren {
      sum += 1
      rootChildren = left.children.left
    }
    return sum
  }
}

extension MerkleTree: Equatable where T: Equatable {
  public static func == (lhs: MerkleTree, rhs: MerkleTree) -> Bool {
    lhs.value == rhs.value
  }
}

extension MerkleTree: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}

extension Digest {
  private var bytes: [UInt8] { Array(makeIterator()) }
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
