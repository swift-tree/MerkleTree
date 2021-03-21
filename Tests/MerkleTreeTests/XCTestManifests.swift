import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(MerkleTreeTests.allTests),
    ]
  }
#endif
