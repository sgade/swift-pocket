//
//  StringInt.swift
//  Pocket
//
//  Created by Sören Gade on 20.02.22.
//


import Foundation


public struct StringInt {

    private let value: Int

}

// MARK: - ExpressibleByStringLiteral

extension StringInt: ExpressibleByStringLiteral {

    public init(stringLiteral value: StringLiteralType) {
        self.value = Int(value) ?? 0
    }

}

// MARK: - Decodable

extension StringInt: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        self.init(stringLiteral: stringValue)
    }

}

// MARK: - Encodable

extension StringInt: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(value)")
    }

}
