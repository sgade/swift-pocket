//
//  NumberedArray.swift
//  Pocket
//
//  Created by Sören Gade on 19.02.22.
//


import Foundation

/// An array that is represented as an object with numbered keys for each item.
///
/// The index always starts at `1`.
///
/// Example:
/// ```json
/// {
///     "1": {
///         ... Item 1
///     },
///     "2": {
///         ... Item 2
///     }
/// }
/// ```
public struct NumberedArray<T> {

    private typealias DictionaryRepresentation = [String: T]

    /// Index value of the first item.
    private let startIndex = 1

    private let values: [T]

}

// MARK: - ExpressibleByArrayLiteral

extension NumberedArray: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: T...) {
        values = elements
    }

}

// MARK: - Decodable

extension NumberedArray: Decodable where T: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let itemDict = try container.decode(DictionaryRepresentation.self)
        values = itemDict.values.map { $0 }
    }

}

// MARK: - Encodable

extension NumberedArray: Encodable where T: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        var dict: DictionaryRepresentation = [:]
        for (index, value) in values.enumerated() {
            dict["\(index + startIndex)"] = value
        }
        try container.encode(dict)
    }

}
