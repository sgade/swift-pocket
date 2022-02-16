//
//  Modify.swift
//  Pocket
//
//  Created by Sören Gade on 28.10.21.
//


import Foundation

// MARK: - Serialization data structures

extension Pocket {

    private enum ActionType: String, Encodable {

        case archive
        // Note: Other actions are omitted.
        // See https://getpocket.com/developer/docs/v3/modify

    }

    private struct SendItemAction: Encodable {

        public enum CodingKeys: String, CodingKey {

            case action
            case itemId = "item_id"

        }


        let action: ActionType
        let itemId: String

    }

    private struct SendResponse: Decodable {

        public enum StatusIndicator: Int, Decodable {

            case failure = 0
            case success = 1

        }

        let status: StatusIndicator

    }

}

// MARK: - Base functions

extension Pocket {

    private func sendRequest(_ url: URL, actions: [SendItemAction]) throws -> SendResponse {
        let actionsJSON = try JSONEncoder().encode(actions)

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "actions", value: String(data: actionsJSON, encoding: .utf8)!),
            URLQueryItem(name: "consumer_key", value: consumerKey),
            URLQueryItem(name: "access_token", value: accessToken ?? "")
        ]

        var request = URLRequest(url: URL(string: components.string!)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "X-Accept")

        let group = DispatchGroup()
        group.enter()

        var body = Data()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { group.leave() }

            guard let data = data else { return }
            body = data
        }
        task.resume()
        group.wait()

        return try JSONDecoder().decode(SendResponse.self, from: body)
    }

    private func send(action: ActionType, for itemId: String) throws {
        let data = [SendItemAction(action: action, itemId: itemId)]
        let url = URL(string: "https://getpocket.com/v3/send")!
        let result = try sendRequest(url, actions: data)

        guard result.status == .success else { throw Errors.unsuccessfulResponse }
    }

}

// MARK: - Actions

extension Pocket {

    public func archive(itemId: String) throws {
        return try send(action: .archive, for: itemId)
    }

}
