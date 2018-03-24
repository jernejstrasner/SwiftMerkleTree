import Foundation
import SwiftCrypto

public indirect enum MerkleTree<T: SwiftCrypto.Hashable> where T.Hash == String {

    case tree(left: MerkleTree<T>, right: MerkleTree<T>, hash: String)
    case leaf(T, hash: String)

    init(withList list: [T], hashAlgorithm: SwiftCrypto.Algorithm = .sha512) {
        self.init(withSlice: ArraySlice(list), hashAlgorithm: hashAlgorithm)
    }

    private init(withSlice slice: ArraySlice<T>, hashAlgorithm: SwiftCrypto.Algorithm = .sha512) {
        assert(slice.count > 0, "Can't initialize a tree with 0 elements")
        switch slice.count {
        case 1:
            let el = slice[slice.startIndex]
            self = .leaf(el, hash: el.digest(hashAlgorithm, key: nil))
        case 2:
            let l = slice[slice.startIndex]
            let r = slice[slice.startIndex+1]
            let lh = l.digest(hashAlgorithm, key: nil)
            let rh = r.digest(hashAlgorithm, key: nil)
            let h = (lh + rh).digest(hashAlgorithm, key: nil)
            self = .tree(left: .leaf(l, hash: lh), right: .leaf(r, hash: rh), hash: h)
        default:
            let split = slice.startIndex + slice.count / 2
            let left = slice[slice.startIndex..<split]
            let right = slice[split..<slice.endIndex]
            let l = MerkleTree(withSlice: left)
            let r = MerkleTree(withSlice: right)
            self = .tree(left: l, right: r, hash: (l.hash+r.hash).digest(hashAlgorithm, key: nil))
        }
    }

    public var hash: String {
        switch self {
        case .tree(left: _, right: _, hash: let h):
            return h
        case .leaf(_, hash: let h):
            return h
        }
    }

    public var leaves: [T] {
        switch self {
        case .tree(left: let left, right: let right, _):
            return left.leaves + right.leaves
        case .leaf(let value, _):
            return [value]
        }
    }

    public var depth: Int {
        switch self {
        case .tree(left: let left, right: let right, _):
            return 1 + max(left.depth, right.depth)
        case .leaf(_, _):
            return 1
        }
    }

    public enum Side {
        case right, left
    }

    public func auditProof(forHash hash: String) -> [(String, Side)]? {
        switch self {
        case .tree(left: let left, right: let right, hash: _):
            if let leftHashes = left.auditProof(forHash: hash) {
                return leftHashes + [(right.hash, .right)]
            }
            if let rightHashes = right.auditProof(forHash: hash) {
                return rightHashes + [(left.hash, .left)]
            }
            return nil
        case .leaf(_, hash: let h):
            return hash == h ? [] : nil
        }
    }

}

public func merkleVerifyData<T>(forLeaf leaf: String, withRoot root: String, nodes: [(String, MerkleTree<T>.Side)], hashAlgorithm: SwiftCrypto.Algorithm = .sha512) -> Bool {
    let currentHash = nodes.reduce(leaf) { (result, node) -> String in
        switch node.1 {
        case .right: return (result + node.0).digest(hashAlgorithm)
        case .left: return (node.0 + result).digest(hashAlgorithm)
        }
    }
    return currentHash == root
}

extension MerkleTree where T: Equatable {

    public func find(value: T) -> Bool {
        switch self {
        case .tree(left: let l, right: let r, _):
            if l.find(value: value) {
                return true
            }
            if r.find(value: value) {
                return true
            }
            return false
        case .leaf(let v, _):
            return v == value
        }
    }

}

extension MerkleTree: Equatable {

    public static func ==(lhs: MerkleTree, rhs: MerkleTree) -> Bool {
        switch (lhs, rhs) {
        case (.tree(_, _, let hash1), .tree(_, _, let hash2)):
            return hash1 == hash2
        case (.leaf(_, let hash1), .leaf(_, let hash2)):
            return hash1 == hash2
        default:
            return false
        }
    }

}

extension MerkleTree: CustomStringConvertible {

    public var description: String {
        switch self {
        case .tree(left: let l, right: let r, _):
            return l.description + " " + r.description
        case .leaf(let v, _):
            return String(describing: v)
        }
    }

}
