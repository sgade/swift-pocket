//
//  Pocket+Modify.swift
//  Pocket
//
//  Created by Sören Gade on 28.10.21.
//


import Foundation

// MARK: Serialization data structures

private protocol ActionParameters: Encodable {

    var time: Int? { get }

}

// See https://getpocket.com/developer/docs/v3/modify
extension Pocket {

    public typealias ModifyItemsResults = [Bool]

    public static let modifyUrl = URL(string: "https://getpocket.com/v3/send")!

    public enum ActionType: String, Encodable {

        case add
        case archive
        case readd
        case favorite
        case unfavorite
        case delete
        case addTags        = "tags_add"
        case removeTags     = "tags_remove"
        case replaceTags    = "tags_replace"
        case clearTags      = "tags_clear"
        case renameTag      = "tag_rename"
        case deleteTag      = "tag_delete"

    }

    private struct SendResponse: Decodable {

        private enum CodingKeys: String, CodingKey {

            case status
            case actionResults  = "action_results"

        }

        let actionResults: ModifyItemsResults
        let status: Status

    }

}

extension Pocket {

    public struct ModifyItemParameters: ActionParameters {

        private enum CodingKeys: String, CodingKey {

            case action
            case id     = "item_id"
            case time

        }

        let action: ActionType
        let id: StringInt
        let time: Int?

        public init(action: ActionType, id: StringInt, time: Int? = nil) {
            self.action = action
            self.id = id
            self.time = time
        }

    }

}

// MARK: - Base functions

extension Pocket {

    private func sendRequest<Action>(_ url: URL, actions: [Action], completion: @escaping (Result<SendResponse, Error>) -> Void) where Action: ActionParameters {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

        do {
            let actionsJSON = try JSONEncoder().encode(actions)

            components.queryItems = [
                URLQueryItem(name: "actions", value: String(data: actionsJSON, encoding: .utf8)!),
                URLQueryItem(name: "consumer_key", value: consumerKey),
                URLQueryItem(name: "access_token", value: accessToken ?? "")
            ]
        } catch {
            return completion(.failure(error))
        }

        var request = URLRequest(url: URL(string: components.string!)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "X-Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return completion(.failure(error!))
            }
            guard let data = data else {
                return completion(.failure(Errors.unsuccessfulResponse))
            }

            do {
                let body = try JSONDecoder().decode(SendResponse.self, from: data)
                completion(.success(body))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    private func send<Action>(actions: [Action], completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) where Action: ActionParameters {
        sendRequest(Pocket.modifyUrl, actions: actions) { result in
            switch result {
            case .success(let response):
                guard response.status == .success else {
                    return completion(.failure(Errors.unsuccessfulResponse))
                }
                return completion(.success(response.actionResults))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }

}

// MARK: - Actions

extension Pocket {

    public struct AddItemParameters: ActionParameters {

        private enum CodingKeys: String, CodingKey {

            case action
            case id         = "item_id"
            case tweetId    = "ref_id"
            case tags
            case time
            case title
            case url

        }

        let action = ActionType.add
        let id: StringInt
        let tweetId: String?
        let tags: String?
        let time: Int?
        let title: String?
        let url: String?

        public init(id: StringInt,
                    tweetId: String? = nil,
                    tags: [String]? = nil,
                    time: Int? = nil,
                    title: String? = nil,
                    url: String? = nil) {
            self.id = id
            self.tweetId = tweetId
            self.tags = tags?.joined(separator: ",")
            self.time = time
            self.title = title
            self.url = url
        }

    }

    public func add(items: [AddItemParameters]) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            add(items: items, completion: continuation.resume)
        }
    }

    public func add(items: [AddItemParameters], completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        send(actions: items, completion: completion)
    }

}

// MARK: Archive

extension Pocket {

    public func archive(itemIds: [StringInt]) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            archive(itemIds: itemIds, completion: continuation.resume(with:))
        }
    }

    public func archive(itemIds: [StringInt], completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        let actions = itemIds.map { ModifyItemParameters(action: .archive, id: $0) }
        send(actions: actions, completion: completion)
    }

}

// MARK: Readd

extension Pocket {

    public func readd(itemIds: [StringInt]) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            readd(itemIds: itemIds, completion: continuation.resume)
        }
    }

    public func readd(itemIds: [StringInt], completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        let actions = itemIds.map { ModifyItemParameters(action: .readd, id: $0) }
        send(actions: actions, completion: completion)
    }

}

// MARK: Favorite

extension Pocket {

    public func favorite(itemIds: [StringInt]) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            favorite(itemIds: itemIds, completion: continuation.resume)
        }
    }

    public func favorite(itemIds: [StringInt], completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        let actions = itemIds.map { ModifyItemParameters(action: .favorite, id: $0) }
        send(actions: actions, completion: completion)
    }

}

// MARK: Unfavorite

extension Pocket {

    public func unfavorite(itemIds: [StringInt]) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            unfavorite(itemIds: itemIds, completion: continuation.resume)
        }
    }

    public func unfavorite(itemIds: [StringInt], completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        let actions = itemIds.map { ModifyItemParameters(action: .unfavorite, id: $0) }
        send(actions: actions, completion: completion)
    }

}

// MARK: Delete

extension Pocket {

    public func delete(itemIds: [StringInt]) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            delete(itemIds: itemIds, completion: continuation.resume)
        }
    }

    public func delete(itemIds: [StringInt], completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        let actions = itemIds.map { ModifyItemParameters(action: .delete, id: $0) }
        send(actions: actions, completion: completion)
    }

}

// MARK: Add tags

extension Pocket {

    public struct TagsParameters: ActionParameters {

        private enum CodingKeys: String, CodingKey {

            case action
            case id         = "item_id"
            case tags
            case time

        }

        let action: ActionType
        let id: StringInt
        let tags: [String]
        let time: Int?

        public init(action: ActionType,
                    id: StringInt,
                    tags: [String],
                    time: Int? = nil) {
            self.action = action
            self.id = id
            self.tags = tags
            self.time = time
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(action, forKey: .action)
            try container.encode(id, forKey: .id)
            try container.encode(tags.joined(separator: ","), forKey: .tags)
            try container.encode(time, forKey: .time)
        }

    }

    public func add(tags: [String], to itemIds: [StringInt]) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            add(tags: tags, to: itemIds, completion: continuation.resume)
        }
    }

    public func add(tags: [String], to itemIds: [StringInt], completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        let actions = itemIds.map { TagsParameters(action: .addTags, id: $0, tags: tags) }
        send(actions: actions, completion: completion)
    }

}

// MARK: Remove tags

extension Pocket {

    public func remove(tags: [String], from itemIds: [StringInt]) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            remove(tags: tags, from: itemIds, completion: continuation.resume)
        }
    }

    public func remove(tags: [String], from itemIds: [StringInt], completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        let actions = itemIds.map { TagsParameters(action: .removeTags, id: $0, tags: tags) }
        send(actions: actions, completion: completion)
    }

}

// MARK: Replace tags

extension Pocket {

    public func replace(tags: [String], on itemIds: [StringInt]) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            replace(tags: tags, on: itemIds, completion: continuation.resume)
        }
    }

    public func replace(tags: [String], on itemIds: [StringInt], completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        let actions = itemIds.map { TagsParameters(action: .replaceTags, id: $0, tags: tags) }
        send(actions: actions, completion: completion)
    }

}

// MARK: Clear tags

extension Pocket {

    public func clearTags(itemIds: [StringInt]) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            clearTags(itemIds: itemIds, completion: continuation.resume)
        }
    }

    public func clearTags(itemIds: [StringInt], completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        let actions = itemIds.map { ModifyItemParameters(action: .clearTags, id: $0) }
        send(actions: actions, completion: completion)
    }

}

// MARK: Rename tag

extension Pocket {

    public struct RenameTagParameters: ActionParameters {

        private enum CodingKeys: String, CodingKey {

            case action
            case oldTag = "old_tag"
            case newTag = "new_tag"
            case time

        }

        let action = ActionType.renameTag
        let oldTag: String
        let newTag: String
        let time: Int?

        public init(oldTag: String,
                    newTag: String,
                    time: Int? = nil) {
            self.oldTag = oldTag
            self.newTag = newTag
            self.time = time
        }

    }

    public func renameTag(from oldTag: String, to newTag: String) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            renameTag(from: oldTag, to: newTag, completion: continuation.resume)
        }
    }

    public func renameTag(from oldTag: String, to newTag: String, completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        let action = RenameTagParameters(oldTag: oldTag, newTag: newTag)
        send(actions: [action], completion: completion)
    }

}

// MARK: Delete tag

extension Pocket {

    public struct DeleteTagParameters: ActionParameters {

        let action = ActionType.deleteTag
        let tag: String
        let time: Int?

        public init(tag: String,
                    time: Int? = nil) {
            self.tag = tag
            self.time = time
        }

    }

    public func delete(tag: String) async throws -> ModifyItemsResults {
        try await withCheckedThrowingContinuation { continuation in
            delete(tag: tag, completion: continuation.resume)
        }
    }

    public func delete(tag: String, completion: @escaping (Result<ModifyItemsResults, Error>) -> Void) {
        let action = DeleteTagParameters(tag: tag)
        send(actions: [action], completion: completion)
    }

}
