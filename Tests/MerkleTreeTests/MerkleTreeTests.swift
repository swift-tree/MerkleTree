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

    tree = MerkleTree.create(fromBlobs: [helloText, worldText].map { Data($0.utf8) })
    let rootHash = Data((Data(helloText.utf8).doubleHashedHex + Data(worldText.utf8).doubleHashedHex).utf8).doubleHashedHex

    XCTAssertEqual(
      tree,
      .init(.init(hash: rootHash), .init(blob: Data(helloText.utf8)), .init(blob: Data(worldText.utf8)))
    )

    XCTAssertEqual(tree.height, 2)
  }

  func test_toPowersOfTwo_intMax() {
    XCTAssertEqual(MerkleTree.toPowersOfTwo(Int.max), [62, 61, 60, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42,
                                            41, 40, 39, 38, 37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22,
                                            21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0])
  }

  func test_toPowersOfTwo_35() {
    XCTAssertEqual(MerkleTree.toPowersOfTwo(35), [5, 1, 0])
  }

  func test_splitToSumOfPowerOfTwo() {
    XCTAssertEqual(MerkleTree.splitToSumOfPowerOfTwo((1 ... 35).map{$0}), [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
                                                                     18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32],
                                                                    [1, 2], [1]])
  }


  func test_makeSiblings() {
    let right = MerkleTree(hash: "KISA")
    let left = MerkleTree(.init(hash: "UZUN 1"), MerkleTree(hash: "UZUN 2"),  nil)

    tree =  MerkleTree.makeSiblings(left, right)

    XCTAssertEqual(tree.height, 3)
  }

  func test_build_height_massive() {
    let x = 10
    let phrase = (1 ... 1 << x).map(\.description)
    let fullTree = MerkleTree.recursiveFullSiblings(nodes: .init(phrase.map { Data($0.utf8) }.map{MerkleTree(blob: $0)}))
    tree = fullTree

    XCTAssertEqual(tree.height, x + 1)
  }

  func test_create_height_plus_1() {
    let x = 2
    let end = (1 << x) + 1
    let phrase = (1 ... end).map(\.description)
    tree = MerkleTree.create(fromBlobs: phrase.map { Data($0.utf8) })

    XCTAssertEqual(tree.value.hash, "51B6578B40B8E48D424CFDFF74B17F8CF85B25CE7081E89E5BA05E6CEE208E54")
    XCTAssertEqual(tree.height, x + 2)
  }

  func test_contains_single_root() {
    let helloText = "Hello"
    let helloData = Data(helloText.utf8)
    tree = MerkleTree.create(fromBlobs: [helloData])

    //  XCTAssertEqual(tree.find(blob: helloData), tree)
  }

  func test_1() {
    let helloText = "Hello"
    let worldText = "world!"

    tree = MerkleTree
      .create(fromBlobs: [helloText, worldText].map { Data($0.utf8) })
      .fillParent(times: 3)
  }


  func test_contains_double_root() {
    let helloText = "Hello"
    let worldText = "world!"

    tree = MerkleTree.create(fromBlobs: [helloText, worldText].map { Data($0.utf8) })
    let rootHash = Data((Data(helloText.utf8).doubleHashedHex + Data(worldText.utf8).doubleHashedHex).utf8)

    //  XCTAssertEqual(tree.find(blob: rootHash), tree)
  }

  func test_contains_double_leaf() {
    let helloText = "Hello"
    let worldText = "world!"

    tree = MerkleTree.create(fromBlobs: [helloText, worldText].map { Data($0.utf8) })

    //  XCTAssertEqual(tree.find(blob: Data(helloText.utf8)), .init(blob: Data(helloText.utf8)))
  }


  func test_contains_massive_4() {
   let phrase = (1 ... 3).map(\.description)

    tree = MerkleTree.create(fromBlobs: phrase.map { Data($0.utf8) })

    print(tree)
    //   XCTAssertEqual(tree.find(blob: Data("7".utf8)), .init(blob: Data("7".utf8)))
  }

  func test_contains_massive_leaf1() {
    let x = 10
    let max = 1 << x
    let phrase = (1 ... max).map(\.description)

    tree = MerkleTree.create(fromBlobs: phrase.map { Data($0.utf8) })

    //  XCTAssertEqual(tree.find(blob: Data("\(max + 1)".utf8)), .empty)
  }

//  func test_audit() throws {
//    let x = 3
//    let phrase = (1 ... pow(2, x).int).map(\.description)
//
//    let datum = phrase.map { Data($0.utf8) }
//    let (output, leaves) = MerkleTree.build(fromBlobs: datum)
//    tree = output
//
//    let targetHash = Data(7.description.utf8).doubleHashedHex
//
//    let auditTrail = tree.getAuditTrail(for: targetHash, leaves: leaves)
//    XCTAssertEqual(
//      auditTrail,
//      [
//        PathHash(try XCTUnwrap(tree.children.right?.children.right?.children.right?.value.hash), leaf: .right),
//        PathHash(try XCTUnwrap(tree.children.right?.children.left?.value.hash), leaf: .left),
//        PathHash(try XCTUnwrap(tree.children.left?.value.hash), leaf: .left)
//      ]
//    )
//
//    XCTAssertTrue(tree.audit(itemHash: targetHash, auditTrail: auditTrail))
//  }
//
//  func test_audit1() throws {
//    let phrase = (1 ... 5).map(\.description)
//
//    let datum = phrase.map { Data($0.utf8) }
//    let (output, leaves) = MerkleTree.build(fromBlobs: datum)
//    tree = output
//
//    let targetHash = Data(7.description.utf8).doubleHashedHex
//
//    let auditTrail = tree.getAuditTrail(for: targetHash, leaves: leaves)
//    XCTAssertEqual(
//      auditTrail,
//      [
//        PathHash(try XCTUnwrap(tree.children.right?.children.right?.children.right?.value.hash), leaf: .right),
//        PathHash(try XCTUnwrap(tree.children.right?.children.left?.value.hash), leaf: .left),
//        PathHash(try XCTUnwrap(tree.children.left?.value.hash), leaf: .left)
//      ]
//    )
//
//    XCTAssertTrue(tree.audit(itemHash: targetHash, auditTrail: auditTrail))
//  }

  static var allTests = [
    ("test_build", test_build),
  ]
}

private extension Decimal {
  var int: Int {
    NSDecimalNumber(decimal: self).intValue
  }
}
