// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "MerkleTree",
    products: [
        .library(
            name: "MerkleTree",
            targets: ["MerkleTree"]),
   ],
    dependencies: [
        .package(url: "https://github.com/jernejstrasner/SwiftCrypto.git", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "MerkleTree",
            dependencies: ["SwiftCrypto"]),
        .testTarget(
            name: "MerkleTreeTests",
            dependencies: ["MerkleTree"]),
    ]
)
