import BinaryTree
import CryptoKit
import Foundation

//  func find(blob: Data) -> Self {
//    switch self {
//    case .empty:
//      return .empty
//    case .node(value: .init(blob: blob), _):
//      return self
//    case .node(value: _, let children):
//      let left = children.left.find(blob: blob)
//      if case .empty = left {
//        return children.right.find(blob: blob)
//      } else {
//        return left
//      }
//    }
//  }
//}
extension MerkleTree: CustomStringConvertible {
  public var description: String {
    "\(value.hash) \(String(describing: children.left?.description)) \(String(describing: children.right?.description))"
  }
}

public struct PathHash: Hashable {
  public enum Leaf { case left, right }
  public let hash: String
  public let leaf: Leaf

  public init(_ hash: String, leaf: Leaf){
    self.hash = hash
    self.leaf = leaf
  }
}

public extension MerkleTree {
  func getAuditTrail(for itemHash: String, leaves: [MerkleTree]) -> [PathHash] {
    guard let targetLeave = leaves.first(where: { $0.value.hash == itemHash }) else { return [] }
    var path = [PathHash]()

    var currentParent: MerkleTree? = targetLeave.parent
    var siblingHash = itemHash
    while let parent = currentParent,
          let leftHash = parent.children.left?.value.hash,
          let rightHash = parent.children.right?.value.hash {

      if leftHash == siblingHash {
        path.append(PathHash(rightHash, leaf: .right))
      } else if rightHash == siblingHash {
        path.append(PathHash(leftHash, leaf: .left))
      }

      siblingHash = parent.value.hash
      currentParent = parent.parent
    }

    return path
  }
  static func duplicate(_ tree: MerkleTree, times: Int) -> MerkleTree {
    let root = tree
    var branch = root
    for _ in 1..<times {
      let new = MerkleTree(hash: tree.value.hash)
      branch.children.right = new
      new.parent = branch
      branch = new
    }
    return root
  }

  static  func insert(tree: MerkleTree? = nil,  _ first: MerkleTree, _ second: MerkleTree?) -> MerkleTree {
    let parent = second.flatMap{MerkleTree.createParent(first, $0)}
      ?? (tree?.height).map{duplicate(first, times: $0)}
      ?? first
    guard let tree = tree else {return parent}
    return MerkleTree.createParent(tree, parent)
  }

  static func build(fromBlobs: [Data]) -> MerkleTree? {
    var blobs = fromBlobs
    var root: MerkleTree? = nil
    while !blobs.isEmpty {
      let first = blobs.removeFirst()
      let second: Data? = blobs.first != nil ? blobs.removeFirst() : nil
      root = insert(tree: root, MerkleTree(blob: first), second.map{MerkleTree(blob: $0)})
    }
    return root
  }

  func audit(itemHash: String, auditTrail: [PathHash]) -> Bool {
    var pathHashes = auditTrail
    var siblingHash = itemHash

    while !pathHashes.isEmpty {
      let pathHash = pathHashes.removeFirst()
      let parentHashes = pathHash.leaf == .left ? (pathHash.hash + siblingHash) : (siblingHash + pathHash.hash)
      siblingHash = Data(parentHashes.utf8).doubleHashedHex
    }

    return siblingHash == value.hash
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

public extension MerkleTree {
  convenience init(hash: String) {
    self.init(MerkleNode(hash: hash))
  }

  convenience init(blob: Data) {
    self.init(MerkleNode(blob: blob))
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

public extension MerkleTree {
  static func createParent(_ left: MerkleTree, _ right: MerkleTree) -> MerkleTree {
    let leftHash = left.value.hash
    let rightHash = right.value.hash
    let new = MerkleTree(hash: Data((leftHash + rightHash).utf8).doubleHashedHex)
    new.add(left, right)
    return new
  }
}

public class TwoWayBinaryTree<T> {
  public var value: T

  public weak var parent: TwoWayBinaryTree<T>?
  public var children: (left: TwoWayBinaryTree<T>?, right: TwoWayBinaryTree<T>?)

  public init(_ value: T, _ left: TwoWayBinaryTree<T>? = nil, _ right:TwoWayBinaryTree<T>? = nil) {
    self.value = value
    children = (nil, nil)
  }

  public func add(_ left: TwoWayBinaryTree<T>?, _ right:TwoWayBinaryTree<T>?) {
    children = (left, right)
    left?.parent = self
    right?.parent = self
  }
}

