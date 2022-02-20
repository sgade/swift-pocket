//
//  StringBool.swift
//  Pocket
//
//  Created by Sören Gade on 19.02.22.
//


import Foundation


public struct StringBool {

    private let value: Bool

}

// MARK: - ExpressibleByBooleanLiteral

extension StringBool: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: BooleanLiteralType) {
        self.value = value
    }

}

// MARK: - Decodable

extension StringBool: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        value = stringValue == "1"
    }

}

// MARK: - Encodable

extension StringBool: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value ? "1" : "0")
    }

}
