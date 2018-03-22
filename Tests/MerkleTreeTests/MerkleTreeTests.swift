import XCTest
@testable import MerkleTree

class MerkleTreeTests: XCTestCase {

    let tree = MerkleTree(withList: ["a", "b", "c", "d", "e", "f", "g"])

    func testSimpleHash() {
        let tree = MerkleTree(withList: ["a", "b"])
        XCTAssertEqual(tree.hash, ("a".sha512 + "b".sha512).sha512)
    }

    func testLeaves() {
        XCTAssertEqual(tree.leaves, ["a", "b", "c", "d", "e", "f", "g"])
    }

    func testFind() {
        XCTAssertTrue(tree.find(value: "c"))
        XCTAssertTrue(tree.find(value: "g"))
        XCTAssertFalse(tree.find(value: "h"))
        XCTAssertFalse(tree.find(value: "suhfa9"))
    }

    func testDepth() {
        XCTAssertEqual(tree.depth, 4)
        let one = MerkleTree(withList: ["a", "b"])
        XCTAssertEqual(one.depth, 2)
    }

    func testBuildTree() {
        let elements = ["a", "b", "c", "d", "e", "f", "g", "h"]
        let tree = MerkleTree(withList: elements)
        XCTAssertEqual(tree.depth, 4)
        XCTAssertEqual(tree.leaves, elements)
    }

    func testAuditProof() {
        let proof = tree.auditProof(forHash: "d".sha512)!
        let test = [
            "87c568e037a5fa50b1bc911e8ee19a77c4dd3c22bce9932f86fdd8a216afe1681c89737fada6859e91047eece711ec16da62d6ccb9fd0de2c51f132347350d8c",
            "f4f1e677f44c63d0c6ad86e13a0d4b743fa0a20559dc4650ab2e4356cdef5d8a370a024d9b8819831f5735a5b34d9002d93c13134f0dec2915a23a4f5abe0385",
            "2449badf7609235b564daabc1ae1ee7276fe4d5015f938a21dec8864f8d81aaeb656c318afdead73d3d2dad05eef81f6b81990f27f8224316c5aad12b2860079"
        ]
        XCTAssertEqual(test, proof)
    }

    static var allTests = [
        ("testSimpleHash", testSimpleHash),
        ("testLeaves", testLeaves),
        ("testFind", testFind),
        ("testDepth", testDepth),
        ("testBuildTree", testBuildTree),
        ("testAuditProof", testAuditProof),
    ]

}
