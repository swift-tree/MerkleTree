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
    children.left.flatMap{ left in
      children.right.flatMap{ right in
        max(left.height, right.height)
      }
    }.map{$0 + 1} ?? 1
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
  static func createParent(_ left: MerkleTree, _ right: MerkleTree) -> MerkleTree? {
    let leftHash = left.value.hash
    let rightHash = right.value.hash
    let new = MerkleTree(hash: Data((leftHash + rightHash).utf8).doubleHashedHex)
    new.add(left, right)
    return new
  }

  static func build(fromBlobs blobs: [Data]) -> (tree: MerkleTree, leaves: [MerkleTree]) {
    let datum = blobs.map(MerkleTree.init(blob:))
    var nodeArray = datum

    while nodeArray.count != 1 {
      var tmpArray = [MerkleTree]()
      while !nodeArray.isEmpty {
        let leftNode = nodeArray.removeFirst()
        let rightNode = !nodeArray.isEmpty ? nodeArray.removeFirst() : leftNode
        let new = createParent(leftNode, rightNode)
        if let new = new {
          tmpArray.append(new)
        }
      }

      nodeArray = tmpArray
    }

    return (nodeArray[0], datum)
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

