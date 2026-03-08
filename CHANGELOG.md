# Changelog

All notable changes to MerkleTree will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-08

### Added

- `MerkleTree` — a balanced and unbalanced Merkle tree implementation following the [THEX format](https://adc.sourceforge.io/draft-jchapweske-thex-02.html).
- `MerkleTree.build(fromBlobs:)` — builds a Merkle tree from an array of `Data` blobs.
- `MerkleTree.getAuditTrail(for:leaves:)` — returns an ordered audit trail (`[PathHash]`) for a given leaf hash.
- `MerkleTree.audit(itemHash:auditTrail:)` — verifies an audit trail against the tree root.
- `MerkleTree.generateProof(for:leaves:)` — generates a single-use `MerkleProof` (`~Copyable`) for a leaf hash.
- `MerkleProof.verify(itemHash:)` — verifies a proof and **consumes** it, preventing proof replay.
- `MerkleNode` — a hashable value type wrapping a SHA-256 double-hash string.
- `PathHash` — a hashable value type representing a sibling hash and its position (`.left` / `.right`) in an audit trail.
- Swift Package Manager support targeting macOS 10.15+, iOS 13+, tvOS 13+, and watchOS 6+.
