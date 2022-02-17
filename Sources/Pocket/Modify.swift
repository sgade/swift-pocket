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

    private func sendRequest(_ url: URL, actions: [SendItemAction], completion: @escaping (Result<SendResponse, Error>) -> Void) {
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

    private func send(action: ActionType, for itemId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let data = [SendItemAction(action: action, itemId: itemId)]
        let url = URL(string: "https://getpocket.com/v3/send")!

        sendRequest(url, actions: data) { result in
            switch result {
            case .success(let response):
                guard response.status == .success else {
                    return completion(.failure(Errors.unsuccessfulResponse))
                }
                return completion(.success(()))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }

}

// MARK: - Actions

extension Pocket {

    public func archive(itemId: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            archive(itemId: itemId, completion: continuation.resume(with:))
        }
    }

    public func archive(itemId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        send(action: .archive, for: itemId, completion: completion)
    }

}
