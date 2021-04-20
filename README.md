# MerkleTree

Merkle Tree respecting Tree Hash EXchange format (THEX) in Swift.


#### Balanced Trees
```
              ROOT=IH(E+F)
              /      \
             /        \
       E=IH(A+B)       F=IH(C+D)
       /     \           /    \
       /       \         /      \
A=LH(S1)  B=LH(S2) C=LH(S3)  D=LH(S4)
```

#### Unbalanced Trees
```
                    ROOT=IH(H+E)
                     /        \
                    /          \
             H=IH(F+G)          E
             /       \           \
             /         \           \
      F=IH(A+B)       G=IH(C+D)     E
      /     \           /     \      \
      /       \         /       \      \
A=LH(S1)  B=LH(S2) C=LH(S3)  D=LH(S4) E=LH(S5)
```

### Swift Package Manager
#### The [Swift Package Manager](https://swift.org/package-manager/) automates the distribution of Swift code. To use MerkleTree with SPM, add a dependency to your `Package.swift` file: 


```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/swift-tree/MerkleTree.git", ...)
    ]
)
```

Erk Ekin

