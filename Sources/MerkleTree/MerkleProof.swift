import Foundation

/// A single-use cryptographic proof that an item is included in a Merkle tree.
///
/// `MerkleProof` is `~Copyable` to enforce that a proof can only be verified
/// once. This prevents proof replay: once ``verify(itemHash:)`` is called, the
/// proof is consumed and cannot be reused, making the API more robust and
/// secure.
public struct MerkleProof: ~Copyable {
  public let rootHash: String
  private let trail: [PathHash]

  init(rootHash: String, trail: [PathHash]) {
    self.rootHash = rootHash
    self.trail = trail
  }

  /// Verifies that `itemHash` is included in the Merkle tree represented by
  /// this proof. Calling this method **consumes** the proof.
  public consuming func verify(itemHash: String) -> Bool {
    var siblingHash = itemHash
    for pathHash in trail {
      let parentHashes = pathHash.leaf == .left
        ? (pathHash.hash + siblingHash)
        : (siblingHash + pathHash.hash)
      siblingHash = Data(parentHashes.utf8).doubleHashedHex
    }
    return siblingHash == rootHash
  }
}
