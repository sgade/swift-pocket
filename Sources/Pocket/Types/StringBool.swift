//
//  StringBool.swift
//  Pocket
//
//  Created by Sören Gade on 19.02.22.
//


import Foundation


public struct StringBool {

    public static let trueValue = "1"
    public static let falseValue = "0"

    private let value: Bool

}

// MARK: - ExpressibleByBooleanLiteral

extension StringBool: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: BooleanLiteralType) {
        self.value = value
    }

}

// MARK: - CustomStringConvertible

extension StringBool: CustomStringConvertible {

    public var description: String {
        value ? StringBool.trueValue : StringBool.falseValue
    }

}

// MARK: - Decodable

extension StringBool: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        value = stringValue == StringBool.trueValue
    }

}

// MARK: - Encodable

extension StringBool: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }

}
