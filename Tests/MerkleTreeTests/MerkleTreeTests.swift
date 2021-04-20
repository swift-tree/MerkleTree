import MerkleTree
import XCTest

final class MerkleTreeTests: XCTestCase {
  var tree: MerkleTree!

  override func tearDownWithError() throws {
    tree = nil

    try super.tearDownWithError()
  }

  func test_build_two_leaves() {
    let helloText = "Hello"
    let worldText = "world!"

    tree = MerkleTree.build(fromBlobs: [helloText, worldText].map { Data($0.utf8) })
    let rootHash = Data((Data(helloText.utf8).doubleHashedHex + Data(worldText.utf8).doubleHashedHex).utf8).doubleHashedHex

    XCTAssertEqual(
      tree,
      .init(
        .init(hash: rootHash),
        left: .init(blob: Data(helloText.utf8)),
        right: .init(blob: Data(worldText.utf8))
      )
    )
    XCTAssertEqual(tree.height, 2)
  }

  func test_toPowersOfTwo_intMax() {
    XCTAssertEqual(MerkleTree.toPowersOfTwo(Int.max), (0 ... 62).reversed())
  }

  func test_toPowersOfTwo_35() {
    XCTAssertEqual(MerkleTree.toPowersOfTwo(35), [5, 1, 0])
  }

  func test_build_height_massive() {
    let x = 10
    let end = 1 << x
    tree = datum(n: end)

    XCTAssertEqual(tree.height, x + 1)
  }

  func test_build_height_plus_1() {
    let x = 2
    let end = 1 << x + 1
    tree = datum(n: end)

    XCTAssertEqual(tree.value.hash, "51B6578B40B8E48D424CFDFF74B17F8CF85B25CE7081E89E5BA05E6CEE208E54")
    XCTAssertEqual(tree.height, x + 2)
  }

  func test_audit_powerOf2_3_minus1() throws {
    let x = 3
    let end = 1 << x - 1
    tree = datum(n: end)

    XCTAssertEqual(tree.height, 5)
  }

  func test_audit_powerOf2_3_minus2() throws {
    let x = 3
    let end = 1 << x - 2
    tree = datum(n: end)

    XCTAssertEqual(tree.height, x + 1)
  }

  func test_build_height_minus_1() {
    let x = 2
    let end = 1 << x - 1
    tree = datum(n: end)

    XCTAssertEqual(tree.value.hash, "77FCD3566DA22AB55387EB92BF151BFDB6E76EB4E5B1701023C00DCC8E8F44F5")
    XCTAssertEqual(tree.height, x + 1)
  }

  func test_build_height_3minus_2() {
    let x = 3
    let end = 1 << x - 2
    tree = datum(n: end)

    XCTAssertEqual(tree.value.hash, "DBECD5966E8B38C2C59D69C59545BDE92C6B40F1FB5BEF9B49B00FC72A44CCB1")
    XCTAssertEqual(tree.height, x + 1)
  }

  func test_audit_powerOf2_3() throws {
    let x = 3
    let end = 1 << x
    tree = datum(n: end)

    let targetHash = Data(7.description.utf8).doubleHashedHex
    let targetLeave = try XCTUnwrap(tree.children.right?.children.right?.children.left)
    let auditTrail = tree.getAuditTrail(for: targetHash, leaves: [targetLeave])

    XCTAssertEqual(
      auditTrail,
      [
        PathHash(try XCTUnwrap(tree.children.right?.children.right?.children.right?.value.hash), leaf: .right),
        PathHash(try XCTUnwrap(tree.children.right?.children.left?.value.hash), leaf: .left),
        PathHash(try XCTUnwrap(tree.children.left?.value.hash), leaf: .left),
      ]
    )

    XCTAssertTrue(tree.audit(itemHash: targetHash, auditTrail: auditTrail))
  }

  func test_auditTrail_powerOf2_2_plus1_lastTarget() throws {
    let x = 2
    let end = 1 << x + 1
    tree = datum(n: end)

    let targetHash = Data(5.description.utf8).doubleHashedHex
    let targetLeave = try XCTUnwrap(tree.children.right?.children.right?.children.right)
    let auditTrail = tree.getAuditTrail(for: targetHash, leaves: [targetLeave])

    XCTAssertEqual(auditTrail, [PathHash(try XCTUnwrap(tree.children.left?.value.hash), leaf: .left)])
    XCTAssertTrue(tree.audit(itemHash: targetHash, auditTrail: auditTrail))
  }

  func test_auditTrail_powerOf2_3_minus1_lastTarget() throws {
    let x = 3
    let end = 1 << x - 1
    tree = datum(n: end)

    let targetHash = Data(7.description.utf8).doubleHashedHex
    let targetLeave = try XCTUnwrap(tree.children.right?.children.right?.children.right?.children.right)
    let auditTrail = tree.getAuditTrail(for: targetHash, leaves: [targetLeave])

    XCTAssertEqual(auditTrail, [PathHash(try XCTUnwrap(tree.children.left?.value.hash), leaf: .left)])
    XCTAssertTrue(tree.audit(itemHash: targetHash, auditTrail: auditTrail))
  }

  func test_auditTrail_powerOf2_3_minus1_6th() throws {
    let x = 3
    let end = 1 << x - 1
    tree = datum(n: end)

    let targetLeave = try XCTUnwrap(tree.children.left?.children.right?.children.right?.children.right)
    let targetHash = Data(6.description.utf8).doubleHashedHex

    let auditTrail = tree.getAuditTrail(for: targetHash, leaves: [targetLeave])

    XCTAssertEqual(
      auditTrail,
      [
        PathHash(try XCTUnwrap(tree.children.left?.children.right?.children.right?.children.left?.value.hash), leaf: .left),
        PathHash(try XCTUnwrap(tree.children.left?.children.left?.value.hash), leaf: .left),
        PathHash(try XCTUnwrap(tree.children.right?.value.hash), leaf: .right),
      ]
    )
  }

  func test_audit_5() throws {
    let x = 2
    let end = 1 << x + 1
    tree = datum(n: end)

    let targetLeave = try XCTUnwrap(tree.children.right?.children.right?.children.right)
    let targetHash = Data(5.description.utf8).doubleHashedHex

    let auditTrail = tree.getAuditTrail(for: targetHash, leaves: [targetLeave])

    XCTAssertTrue(tree.audit(itemHash: targetHash, auditTrail: auditTrail))
  }

  func test_audit_7() throws {
    let x = 3
    let end = 1 << x - 1
    tree = datum(n: end)

    let targetLeave = try XCTUnwrap(tree.children.right?.children.right?.children.right)
    let targetHash = Data(7.description.utf8).doubleHashedHex

    let auditTrail = tree.getAuditTrail(for: targetHash, leaves: [targetLeave])

    XCTAssertTrue(tree.audit(itemHash: targetHash, auditTrail: auditTrail))
  }

  func test_audit_6() throws {
    let x = 3
    let end = 1 << x - 1

    tree = datum(n: end)
    let targetLeave = try XCTUnwrap(tree.children.left?.children.right?.children.right?.children.right)
    let targetHash = Data(6.description.utf8).doubleHashedHex

    let auditTrail = tree.getAuditTrail(for: targetHash, leaves: [targetLeave])

    XCTAssertTrue(tree.audit(itemHash: targetHash, auditTrail: auditTrail))
  }

  private func datum(n: Int) -> MerkleTree {
    .build(fromBlobs: (1 ... n)
            .map(\.description.utf8)
            .map { Data($0) })
  }

  static var allTests = [
    ("test_build_two_leaves", test_build_two_leaves),
    ("test_toPowersOfTwo_intMax", test_toPowersOfTwo_intMax),
    ("test_toPowersOfTwo_35", test_toPowersOfTwo_35),
    ("test_build_height_massive", test_build_height_massive),
    ("test_build_height_plus_1", test_build_height_plus_1),
    ("test_audit_powerOf2_3_minus1", test_audit_powerOf2_3_minus1),
    ("test_audit_powerOf2_3_minus2", test_audit_powerOf2_3_minus2),
    ("test_build_height_minus_1", test_build_height_minus_1),
    ("test_build_height_3minus_2", test_build_height_3minus_2),
    ("test_audit_powerOf2_3", test_audit_powerOf2_3),
    ("test_auditTrail_powerOf2_2_plus1_lastTarget", test_auditTrail_powerOf2_2_plus1_lastTarget),
    ("test_auditTrail_powerOf2_3_minus1_lastTarget", test_auditTrail_powerOf2_3_minus1_lastTarget),
    ("test_auditTrail_powerOf2_3_minus1_6th", test_auditTrail_powerOf2_3_minus1_6th),
    ("test_audit_5", test_auditTrail_powerOf2_3_minus1_lastTarget),
    ("test_audit_7", test_audit_7),
    ("test_audit_6", test_audit_6),
  ]
}

private extension Decimal {
  var int: Int {
    NSDecimalNumber(decimal: self).intValue
  }
}
