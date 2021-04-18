public struct PathHash: Hashable {
  public enum Leaf { case left, right }
  public let hash: String
  public let leaf: Leaf

  public init(_ hash: String, leaf: Leaf) {
    self.hash = hash
    self.leaf = leaf
  }
}
