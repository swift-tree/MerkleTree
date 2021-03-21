import BinaryTree
import CryptoKit
import MerkleTree
import XCTest

final class MerkleTreeTests: XCTestCase {
  var tree: MerkleTree!

  override func setUpWithError() throws {
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    tree = nil

    try super.tearDownWithError()
  }

  func test_build() {
    let helloText = "Hello"
    let worldText = "world!"

    tree = MerkleTree.build(fromBlobs: [helloText, worldText].map{ Data($0.utf8) })
    let rootHash = "ABAC91BFE7F393A290E4A4A30E65C53108D278A24CCC512468D3449A771EC70D634730FE3D9312E880302F22419486362C1EDF56C42F32016A4B24A24C0A14A5"

    XCTAssertEqual(
      tree,
      .node(value: .init(hash: Data(rootHash.utf8).doubleHashedHex), .init(.leaf(.init(blob: Data(helloText.utf8))), .leaf(.init(blob: Data(worldText.utf8)))))
    )
    XCTAssertEqual(tree.height, 2)
  }

  func test_build1() {
    let x = 10
    let phrase = (1...pow(2, x).int).map(\.description)

    tree = MerkleTree.build(fromBlobs: phrase.map{ Data($0.utf8) })

    XCTAssertEqual(tree.height, (x+1))
  }

  static var allTests = [
    ("test_build", test_build),
  ]
}

private extension Decimal {
  var int: Int {
    NSDecimalNumber(decimal: self).intValue
  }
}
