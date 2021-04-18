import BinaryTree
import CryptoKit
import Foundation

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
    while let parent = currentParent {
      if let leftHash = parent.children.left?.value.hash {
        if let rightHash = parent.children.right?.value.hash {
          if leftHash == siblingHash {
            path.append(PathHash(rightHash, leaf: .right))
          } else if rightHash == siblingHash {
            path.append(PathHash(leftHash, leaf: .left))
          }
        }
      }

      siblingHash = parent.value.hash
      currentParent = parent.parent
    }
    return path
  }

  func fillParent(times: Int) -> MerkleTree {
    var branch = self
    for _ in 0..<times {
      let new = MerkleTree(hash: self.value.hash)
      new.add(left: nil, right: branch)
      branch.parent = new
      branch = new
    }
    return branch
  }

  static func toPowersOfTwo(_ num: Int) -> [Int] {
    let binary = String(num, radix: 2)
    return binary
      .enumerated()
      .filter{$1 == "1"}
      .map{binary.count - $0.offset - 1}
  }

//  static func splitToSumOfPowerOfTwo<T>(_ arr: [T]) -> [ArraySlice<T>] {
//     toPowersOfTwo(arr.count)
//      .map{1 << $0}
//      .map{arr.prefix($0)}
//  }

  static func build(fromBlobs: [Data]) -> MerkleTree {
    let leaves = fromBlobs.map{MerkleTree(blob: $0)}
    let powers = toPowersOfTwo(leaves.count)
    var roots = [MerkleTree]()

    for power in powers {
      if power == 0, let last = leaves.last  {
        roots.append(last)
      } else {
        let firstN = leaves.prefix(1 << power)
        roots.append(recursiveFullSiblings(nodes: firstN))
      }
    }

    return recursiveFullSiblings(nodes: .init(roots))
  }

  static func recursiveFullSiblings(nodes: ArraySlice<MerkleTree>) -> MerkleTree {
    let count = nodes.count
    if count == 0 {fatalError()}
    if count == 1, let first = nodes.first {return first}
    if count == 2, let first = nodes.first, let last = nodes.last {
      return makeSiblings(first, last)
    } else {
      let half = (count / 2) + (count % 2)
      return makeSiblings(
        recursiveFullSiblings(nodes: nodes.prefix(half)),
        recursiveFullSiblings(nodes: nodes.suffix(count - half))
      )
    }
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
  static func makeSiblings(_ left: MerkleTree, _ right: MerkleTree) -> MerkleTree {
    let heightDifference = left.height - right.height

    let leftHash = left.value.hash
    let rightHash = right.value.hash
    let new = MerkleTree(hash: Data((leftHash + rightHash).utf8).doubleHashedHex)
    new.add(left: left, right: right.fillParent(times: heightDifference))
    return new
  }
}

public class TwoWayBinaryTree<T> {
  public var value: T

  public weak var parent: TwoWayBinaryTree<T>?
  public var children: (left: TwoWayBinaryTree<T>?, right: TwoWayBinaryTree<T>?)

  public init(_ value: T, _ left: TwoWayBinaryTree<T>? = nil, _ right: TwoWayBinaryTree<T>? = nil) {
    self.value = value
    children = (left, right)
  }

  public func add(left: TwoWayBinaryTree<T>?, right:TwoWayBinaryTree<T>?) {
    children = (left, right)
    left?.parent = self
    right?.parent = self
  }
}

