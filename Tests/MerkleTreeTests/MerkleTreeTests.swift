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

    tree = MerkleTree.build(fromBlobs: [helloText, worldText].map { Data($0.utf8) }).tree
    let rootHash = Data((Data(helloText.utf8).doubleHashedHex + Data(worldText.utf8).doubleHashedHex).utf8).doubleHashedHex

    XCTAssertEqual(
     tree,
      .init(.init(hash: rootHash), .init(blob: Data(helloText.utf8)), .init(blob: Data(worldText.utf8)))
    )

    XCTAssertEqual(tree.height, 2)
  }

  func test_build_height_massive() {
    let x = 10
    let phrase = (1 ... pow(2, x).int).map(\.description)

    tree = MerkleTree.build(fromBlobs: phrase.map { Data($0.utf8) }).tree

    XCTAssertEqual(tree.height, x + 1)
  }

  func test_contains_single_root() {
    let helloText = "Hello"
    let helloData = Data(helloText.utf8)
    tree = MerkleTree.build(fromBlobs: [helloData]).tree

  //  XCTAssertEqual(tree.find(blob: helloData), tree)
  }

  func test_contains_double_root() {
    let helloText = "Hello"
    let worldText = "world!"

    tree = MerkleTree.build(fromBlobs: [helloText, worldText].map { Data($0.utf8) }).tree
    let rootHash = Data((Data(helloText.utf8).doubleHashedHex + Data(worldText.utf8).doubleHashedHex).utf8)

  //  XCTAssertEqual(tree.find(blob: rootHash), tree)
  }

  func test_contains_double_leaf() {
    let helloText = "Hello"
    let worldText = "world!"

    tree = MerkleTree.build(fromBlobs: [helloText, worldText].map { Data($0.utf8) }).tree

 //   XCTAssertEqual(tree.find(blob: Data(helloText.utf8)), .init(blob: Data(helloText.utf8)))
  }

  func test_contains_massive_leaf() {
    let x = 10
    let phrase = (1 ... pow(2, x).int).map(\.description)

    tree = MerkleTree.build(fromBlobs: phrase.map { Data($0.utf8) }).tree

 //   XCTAssertEqual(tree.find(blob: Data("7".utf8)), .init(blob: Data("7".utf8)))
  }

  func test_contains_massive_leaf1() {
    let x = 10
    let max = pow(2, x).int
    let phrase = (1 ... max).map(\.description)

    tree = MerkleTree.build(fromBlobs: phrase.map { Data($0.utf8) }).tree

  //  XCTAssertEqual(tree.find(blob: Data("\(max + 1)".utf8)), .empty)
  }

  func test_33() {
    let x = 3
    let phrase = (1 ... pow(2, x).int).map(\.description)

    let datum = phrase.map { Data($0.utf8) }
    let (output, leaves) = MerkleTree.build(fromBlobs: datum)
    tree = output

   XCTAssertTrue(
    MerkleTree.proves(
      blob: Data("7".utf8),
      hashSet: Dictionary(uniqueKeysWithValues: zip(datum.map(\.doubleHashedHex), leaves)), path: [
        .right("022BB953B0E601E5D5101328D8B6E4A9BF0C30A82D5D5ADB265E35982201D1A6"),
        .left("8B91DB63BCCB95A6CB4DA46FE72026615291C719BFDAAB51EFFA87351C80A1F3"),
        .left("BD63101E1A04D1B648E6AA3B65C60C7CEC444528E363F71E272D0A4EF58D0561")
      ])
    )
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
