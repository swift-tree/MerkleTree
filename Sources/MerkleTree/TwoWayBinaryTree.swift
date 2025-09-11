public class TwoWayBinaryTree<T> {
  public var value: T
  public private(set) var height: Int

  weak var parent: TwoWayBinaryTree<T>?
  public var children: (left: TwoWayBinaryTree<T>?, right: TwoWayBinaryTree<T>?)

  public init(_ value: T, left: TwoWayBinaryTree<T>? = nil, right: TwoWayBinaryTree<T>? = nil) {
    self.value = value
    self.height = 1
    children = (left, right)
    updateHeightIfNeeded(left: left, right: right)
  }

  func add(left: TwoWayBinaryTree<T>? = nil, right: TwoWayBinaryTree<T>? = nil) {
    children = (left, right)
    left?.parent = self
    right?.parent = self
    updateHeightIfNeeded(left: left, right: right)
  }
  
  private func updateHeightIfNeeded(left: TwoWayBinaryTree<T>?, right: TwoWayBinaryTree<T>?) {
    let leftHeight = left?.height ?? 0
    let rightHeight = right?.height ?? 0
    height = max(leftHeight, rightHeight) + 1
  }
}
