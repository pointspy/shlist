//
//  Hash.swift
//  Pixel-iOS
//
//  Created by José Donor on 26/11/2018.
//


/// Helper for generating hash values
struct Hash {

	/// Combines hashes to a new hash value
	static func combine(hashes: Int...) -> Int {
		return combine(hashes: hashes)
	}

	/// Combines hashes to a new hash value
	static func combine(hashes: [Int]) -> Int {
		return hashes.reduce(0, combine)
	}

	/// Gets hash value for an array
	public static func hash<T: Hashable>(array: [T]?) -> Int {
		if let array = array {
			return array.reduce(5_381) { ($0 << 5) &+ $0 &+ $1.hashValue }
		}
		else { return 0 }
	}

	/// Gets hash value for an dictionary
	public static func hash<T, U: Hashable>(dictionary: [T: U]?) -> Int {
		if let dictionary = dictionary {
			return dictionary.reduce(5_381) { combine($0, combine($1.key.hashValue, $1.value.hashValue)) }
		}
		else { return 0 }
	}


	// MARK: - Helpers

	private static func combine(_ lhs: Int, _ rhs: Int) -> Int {

		#if arch(x86_64) || arch(arm64)
		let magic: UInt = 0x9e3779b97f4a7c15
		#elseif arch(i386) || arch(arm)
		let magic: UInt = 0x9e3779b9
		#endif

		var lhs = UInt(bitPattern: lhs)
		let rhs = UInt(bitPattern: rhs)
		lhs ^= rhs &+ magic &+ (lhs << 6) &+ (lhs >> 2)

		return Int(bitPattern: lhs)
	}

}
