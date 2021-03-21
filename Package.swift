// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "MerkleTree",
  platforms: [
    .macOS(SupportedPlatform.MacOSVersion.v10_15),
  ],
  products: [
    .library(
      name: "MerkleTree",
      targets: ["MerkleTree"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swift-tree/BinaryTree.git", .exact("1.0.0")),
  ],
  targets: [
    .target(
      name: "MerkleTree",
      dependencies: ["BinaryTree"]
    ),
    .testTarget(
      name: "MerkleTreeTests",
      dependencies: ["MerkleTree", "BinaryTree"]
    ),
  ]
)
