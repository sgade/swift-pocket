//
//  Retrieve.swift
//  Pocket
//
//  Created by Sören Gade on 28.10.21.
//


import Foundation

// MARK: - Serialization data structures

extension Pocket {

    public struct RetrieveParameters {

        public enum State: String {

            case unread
            case archive
            case all


        }

        public enum Tagged {

            case with(String)
            case untagged

        }

        public enum ContentType: String {

            case article
            case video
            case image

        }

        public enum SortOrder: String {

            case newest
            case oldest
            case title
            case site

        }

        public enum DetailType: String {

            case simple
            case complete

        }

        public var state: State?
        public var favorite: Bool?
        public var tag: Tagged?
        public var contentType: ContentType?
        public var sort: SortOrder?
        public var detailType: DetailType?
        public var search: String?
        public var domain: String?
        //public var since: Date?
        public var count: Int?
        public var offset: Int?

        public init(state: State? = nil,
                    favorite: Bool? = nil,
                    tag: Tagged? = nil,
                    contentType: ContentType? = nil,
                    sort: SortOrder? = nil,
                    detailType: DetailType? = nil,
                    search: String? = nil,
                    domain: String? = nil,
                    count: Int? = nil,
                    offset: Int? = nil) {
            self.state = state
            self.favorite = favorite
            self.tag = tag
            self.contentType = contentType
            self.sort = sort
            self.detailType = detailType
            self.search = search
            self.domain = domain
            self.count = count
            self.offset = offset
        }

    }

    private struct GetResponse: Decodable {

        // MARK: Custom parse logic

        private struct ItemList: Decodable {

            let values: [Item]

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                do {
                    // if we have items, they are returned in a dictionary...
                    let dict = try container.decode([String: Item].self)
                    values = dict.map { $0.value }
                } catch DecodingError.typeMismatch(let type, let context) {
                    // ...however, if there are no items, the field type is (empty) array
                    guard type == [String: Item].self else {
                        // throw error if not for this specfic type
                        throw DecodingError.typeMismatch(type, context)
                    }

                    values = (try? container.decode([Item].self)) ?? []
                }
            }

        }

        private let list: ItemList

        // MARK: Public fields

        // NOTE: Other fields are omitted.
        // See https://getpocket.com/developer/docs/v3/retrieve

        var items: [Item] {
            list.values
        }

    }

}

// MARK: - Retrieve items

extension Pocket {

    public func retrieve(with parameters: RetrieveParameters) async throws -> [Item] {
        try await withCheckedThrowingContinuation { continuation in
            retrieve(with: parameters, completion: continuation.resume)
        }
    }

    public func retrieve(with parameters: RetrieveParameters, completion: @escaping (Result<[Item], Error>) -> Void) {
        var data: [String: String] = [:]
        data["detailType"] = parameters.detailType?.rawValue ?? RetrieveParameters.DetailType.complete.rawValue

        if let state = parameters.state {
            data["state"] = state.rawValue
        }

        if let favorite = parameters.favorite {
            data["favorite"] = favorite ? "1" : "0"
        }

        if let tagged = parameters.tag {
            var tagString: String
            switch tagged {
            case .with(let tag):
                tagString = tag
            case .untagged:
                tagString = "_untagged_"
            }
            data["tag"] = tagString
        }

        if let contentType = parameters.contentType {
            data["contentType"] = contentType.rawValue
        }

        if let sortOrder = parameters.sort {
            data["sort"] = sortOrder.rawValue
        }

        if let search = parameters.search {
            data["search"] = search
        }

        if let domain = parameters.domain {
            data["domain"] = domain
        }

        if let count = parameters.count {
            data["count"] = "\(count)"
        }

        if let offset = parameters.offset {
            data["offset"] = "\(offset)"
        }

        let url = URL(string: "https://getpocket.com/v3/get")!
        requestAuthenticated(url: url, data: data) { (result: Result<GetResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
