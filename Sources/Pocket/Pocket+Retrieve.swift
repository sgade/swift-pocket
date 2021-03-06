//
//  Pocket+Retrieve.swift
//  Pocket
//
//  Created by Sören Gade on 28.10.21.
//


import Foundation

// MARK: Serialization data structures

extension Pocket {

    public static let retrieveUrl = URL(string: "https://getpocket.com/v3/get")!

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

        private let list: ObjectList<Item>

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

        let response: GetResponse = try await requestAuthenticated(url: Pocket.retrieveUrl, data: data)
        return response.items
    }

}
