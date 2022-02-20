//
//  Pocket+Add.swift
//  Pocket
//
//  Created by Sören Gade on 31.10.21.
//


import Foundation

// MARK: Serialization data structures

extension Pocket {

    public static let addUrl = URL(string: "https://getpocket.com/v3/add")!

    public struct AddParameters {

        public var url: URL
        public var title: String?
        public var tags: [String]?
        public var tweetId: String?

        public init(url: URL, title: String? = nil, tags: [String]? = nil, tweetId: String? = nil) {
            self.url = url
            self.title = title
            self.tags = tags
            self.tweetId = tweetId
        }

    }

    private struct AddResponse: Decodable {

        public let item: AddedItem
        public let status: Status

    }

}

// MARK: - Add items

extension Pocket {

    @discardableResult
    public func add(with parameters: AddParameters) async throws -> AddedItem {
        try await withCheckedThrowingContinuation { continuation in
            add(with: parameters, completion: continuation.resume)
        }
    }

    public func add(with parameters: AddParameters, completion: @escaping (Result<AddedItem, Error>) -> Void) {
        guard let escapedUrl = parameters.url
                .absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            return completion(.failure(Errors.invalid(value: parameters.url, parameter: "url")))
        }

        var data = [
            "url": escapedUrl
        ]
        if let title = parameters.title?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            data["title"] = title
        }
        if let tags = parameters.tags {
            data["tags"] = tags.joined(separator: ",")
        }
        if let tweetId = parameters.tweetId {
            data["tweet_id"] = tweetId
        }

        requestAuthenticated(url: Pocket.addUrl, data: data) { (result: Result<AddResponse, Error>) in
            switch result {
            case .success(let response):
                return completion(.success(response.item))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }

}
