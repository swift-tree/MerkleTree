import Foundation

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

  private func createParent(times: Int) -> MerkleTree {
    var tree = self
    let hash = value.hash
    for _ in 0..<times {
      let parent = MerkleTree(hash: hash)
      parent.add(right: tree)
      tree.parent = parent
      tree = parent
    }
    return tree
  }

  static func toPowersOfTwo(_ num: Int) -> [Int] {
    let binary = String(num, radix: 2)
    return binary
      .enumerated()
      .filter{$1 == "1"}
      .map{binary.count - $0.offset - 1}
  }

  static func build(fromBlobs: [Data]) -> MerkleTree {
    let leaves = fromBlobs.map(MerkleTree.init(blob: ))
    let roots: [MerkleTree] = toPowersOfTwo(leaves.count)
      .map { power in
        if power == 0, let last = leaves.last  {
          return last
        } else {
          let firstN = leaves.prefix(1 << power)
          return merge(firstN)
        }
      }

    return merge(ArraySlice(roots))
  }

  static func merge(_ nodes: ArraySlice<MerkleTree>) -> MerkleTree {
    let count = nodes.count
    assert(count != 0, "at least one node should be present")
    if count == 1, let first = nodes.first {return first}
    if count == 2, let first = nodes.first, let last = nodes.last {
      return makeSiblings(first, last)
    } else {
      let half = (count / 2) + (count % 2)
      return makeSiblings(merge(nodes.prefix(half)), merge(nodes.suffix(count - half)))
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
}

public extension MerkleTree {
  static func makeSiblings(_ left: MerkleTree, _ right: MerkleTree) -> MerkleTree {
    let heightDifference = left.height - right.height

    let leftHash = left.value.hash
    let rightHash = right.value.hash
    let new = MerkleTree(hash: Data((leftHash + rightHash).utf8).doubleHashedHex)
    new.add(left: left, right: right.createParent(times: heightDifference))
    return new
  }
}
