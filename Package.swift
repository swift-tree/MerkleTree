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
  dependencies: [
    .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "MerkleTree",
      dependencies: [
        .product(name: "Crypto", package: "swift-crypto")
      ]
    ),
    .testTarget(
      name: "MerkleTreeTests",
      dependencies: ["MerkleTree"]
    ),
  ]
)
