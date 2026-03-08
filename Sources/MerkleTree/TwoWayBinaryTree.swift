public final class TwoWayBinaryTree<T: ~Copyable> {
  public var value: T
  public private(set) var height: Int

  weak var parent: TwoWayBinaryTree<T>?
  public var children: (left: TwoWayBinaryTree<T>?, right: TwoWayBinaryTree<T>?)

  public init(_ value: consuming T, left: TwoWayBinaryTree<T>? = nil, right: TwoWayBinaryTree<T>? = nil) {
    self.value = value
    self.height = 1
    children = (left, right)
    updateHeightIfNeeded(left: children.left, right: children.right)
  }

  func add(left: TwoWayBinaryTree<T>? = nil, right: TwoWayBinaryTree<T>? = nil) {
    children = (left, right)
    children.left?.parent = self
    children.right?.parent = self
    updateHeightIfNeeded(left: children.left, right: children.right)
  }
  
  private func updateHeightIfNeeded(left: TwoWayBinaryTree<T>?, right: TwoWayBinaryTree<T>?) {
    let leftHeight = left?.height ?? 0
    let rightHeight = right?.height ?? 0
    height = max(leftHeight, rightHeight) + 1
  }
}
