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
