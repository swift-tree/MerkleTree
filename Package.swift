// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "MerkleTree",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6)
  ],
  products: [
    .library(
      name: "MerkleTree",
      targets: ["MerkleTree"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "MerkleTree",
      dependencies: []
    ),
    .testTarget(
      name: "MerkleTreeTests",
      dependencies: ["MerkleTree"]
    ),
  ]
)
