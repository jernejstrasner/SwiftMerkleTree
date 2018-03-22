// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "MerkleTreeKit",
    products: [
        .library(
            name: "MerkleTreeKit",
            targets: ["MerkleTreeKit"]),
   ],
    dependencies: [
        .package(url: "https://github.com/jernejstrasner/SwiftCrypto.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "MerkleTreeKit",
            dependencies: ["SwiftCrypto"]),
        .testTarget(
            name: "MerkleTreeKitTests",
            dependencies: ["MerkleTreeKit"]),
    ]
)
