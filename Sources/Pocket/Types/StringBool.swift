//
//  StringBool.swift
//  Pocket
//
//  Created by Sören Gade on 19.02.22.
//


import Foundation


public struct StringBool: Codable, ExpressibleByBooleanLiteral {

    private let value: Bool

    // MARK: ExpressibleByBooleanLiteral

    public init(booleanLiteral value: BooleanLiteralType) {
        self.value = value
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        value = stringValue == "1"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value ? "1" : "0")
    }

}
