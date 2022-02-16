//
//  Pocket.swift
//  Pocket
//
//  Created by Sören Gade on 28.10.21.
//


import Foundation


public class Pocket {

    public var accessToken: String?
    public var username: String?

    let consumerKey: String

    var isAuthenticated: Bool {
        accessToken != nil
    }

    public init(consumerKey: String) {
        self.consumerKey = consumerKey
    }

}

// MARK: - Network request

extension Pocket {

    func request<T: Decodable>(url: URL, jsonData: [String: String]) throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "X-Accept")
        request.httpBody = try JSONEncoder().encode(jsonData)

        let group = DispatchGroup()
        group.enter()

        var body = Data()
        var asyncError: Error?
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { group.leave() }

            guard let httpResponse = response as? HTTPURLResponse else {
                asyncError = Errors.unsuccessfulResponse
                return
            }
            guard httpResponse.statusCode == 200 else {
                // see https://getpocket.com/developer/docs/errors
                switch httpResponse.statusCode {
                case 503:
                    asyncError = Errors.serverDownForMaintenance
                default:
                    let errorCode = Int(httpResponse.value(forHTTPHeaderField: "X-Error-Code") ?? "") ?? 0
                    let message = httpResponse.value(forHTTPHeaderField: "X-Error")
                    asyncError = Errors.response(status: httpResponse.statusCode, code: errorCode, message: message ?? "")
                }
                return
            }

            guard let data = data else {
                asyncError = Errors.unsuccessfulResponse
                return
            }
            body = data
        }
        task.resume()
        group.wait()
        guard asyncError == nil else {
            throw asyncError!
        }


        return try JSONDecoder().decode(T.self, from: body)
    }

    func requestAuthenticated<T: Decodable>(url: URL, data: [String: String]) throws -> T {
        if !isAuthenticated {
            throw Errors.notAuthenticated
        }

        var authenticatedData = data
        authenticatedData["consumer_key"] = consumerKey
        authenticatedData["access_token"] = accessToken ?? ""

        return try request(url: url, jsonData: authenticatedData)
    }

}
