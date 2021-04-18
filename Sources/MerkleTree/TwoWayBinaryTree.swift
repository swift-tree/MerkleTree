public class TwoWayBinaryTree<T> {
  public var value: T

  weak var parent: TwoWayBinaryTree<T>?
  public var children: (left: TwoWayBinaryTree<T>?, right: TwoWayBinaryTree<T>?)

  public init(_ value: T, left: TwoWayBinaryTree<T>? = nil, right: TwoWayBinaryTree<T>? = nil) {
    self.value = value
    children = (left, right)
  }

  func add(left: TwoWayBinaryTree<T>? = nil, right: TwoWayBinaryTree<T>? = nil) {
    children = (left, right)
    left?.parent = self
    right?.parent = self
  }
}
