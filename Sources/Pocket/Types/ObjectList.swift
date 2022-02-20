//
//  ObjectList.swift
//  Pocket
//
//  Created by Sören Gade on 20.02.22.
//


import Foundation


/// A list that is represented as a JSON object when it has values.
///
/// If a list has values, its format looks like this:
/// ```json
/// {
///     "item1": { ... },
///     "item2": { ... }
/// }
/// ```
///
/// However, if the list does not contain any values, it is represented as an empty array:
/// ```json
/// []
/// ```
public struct ObjectList<T> {

    public let values: [T]

}

// MARK: - ExpressibleByArrayLiteral

extension ObjectList: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: T...) {
        values = elements
    }

}

// MARK: - Decodable

extension ObjectList: Decodable where T: Decodable {

    private typealias DictionaryType = [String: T]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let dictionary = try container.decode(DictionaryType.self)
            values = dictionary.map { $0.value }
        } catch DecodingError.typeMismatch(let type, let context) {
            guard type == DictionaryType.self else {
                throw DecodingError.typeMismatch(type, context)
            }
            values = (try? container.decode([T].self)) ?? []
        }
    }

}
