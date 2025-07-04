import Crypto

import struct Foundation.Data

final class ContentHash: Equatable {
	static func == (lhs: ContentHash, rhs: ContentHash) -> Bool {
		return lhs.content == rhs.content
	}

	let content: Data
	lazy private(set) var digest = {
		let digest = SHA256.hash(data: content)
		return
			digest
			.map { String(format: "%02x", $0) }
			.joined()
	}()

	init(content: Data) {
		self.content = content
	}

	convenience init?(string: String, encoding: String.Encoding = .utf8) {
		guard let data = string.data(using: encoding)
		else { return nil }
		self.init(content: data)
	}
}
