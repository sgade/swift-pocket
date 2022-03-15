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
    let urlSession: URLSession

    var isAuthenticated: Bool {
        accessToken != nil
    }

    public init(consumerKey: String, urlSession: URLSession = .shared) {
        self.consumerKey = consumerKey
        self.urlSession = urlSession
    }

}

// MARK: - Network request

extension Pocket {

    func request<T: Decodable>(url: URL, jsonData: [String: String]) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "X-Accept")
        request.httpBody = try JSONEncoder().encode(jsonData)

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Errors.unsuccessfulResponse
        }

        guard httpResponse.statusCode == 200 else {
            // see https://getpocket.com/developer/docs/errors
            let errorCode = Int(httpResponse.value(forHTTPHeaderField: "X-Error-Code") ?? "") ?? 0
            let message = httpResponse.value(forHTTPHeaderField: "X-Error") ?? ""
            throw self.error(for: httpResponse.statusCode,
                                errorCode: errorCode,
                                message: message)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private func error(for statusCode: Int, errorCode: Int, message: String) -> Error {
        switch statusCode {
        case 400: return Errors.invalidRequest(code: errorCode, message: message)
        case 401: return Errors.authenticationFailed(code: errorCode, message: message)
        case 403: return Errors.lackingPermission(code: errorCode, message: message)
        case 503: return Errors.serverDownForMaintenance
        default:  return Errors.errorResponse(status: statusCode,
                                              code: errorCode,
                                              message: message)
        }
    }

    func requestAuthenticated<T: Decodable>(url: URL, data: [String: String]) async throws -> T {
        guard isAuthenticated else { throw Errors.notAuthenticated }

        var authenticatedData = data
        authenticatedData["consumer_key"] = consumerKey
        authenticatedData["access_token"] = accessToken ?? ""

        return try await request(url: url, jsonData: authenticatedData)
    }

}
