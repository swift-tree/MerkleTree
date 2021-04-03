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

public enum Mode: Hashable {
  case left(String)
  case right(String)
}

public extension MerkleTree {
  static func proves(blob: Data, hashSet: [String: MerkleTree], path: [Mode]) -> Bool {
    guard let child = hashSet[blob.doubleHashedHex] else {return false}

    var path = path
    var currentParent: MerkleTree? = child.parent

    while let parent = currentParent,
          let leftHash = parent.children.left?.value.hash,
          let rightHash = parent.children.right?.value.hash {

      switch path.removeFirst() {
      case let .left(hash):
        if parent.value.hash == Data((hash + rightHash).utf8).doubleHashedHex {
          currentParent = parent.parent
        }else{
          return false
        }
      case let .right(hash):

          print("left" + Data((hash + rightHash).utf8).doubleHashedHex)
        if parent.value.hash == Data((leftHash + hash).utf8).doubleHashedHex {
          currentParent = parent.parent
        }else{
          return false
        }
      }
    }
    return true
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

