//
//  Pocket+Authentication.swift
//  Pocket
//
//  Created by Sören Gade on 28.10.21.
//


import Foundation

// MARK: - Serialization data structures

extension Pocket {

    public static let requestTokenUrl = URL(string: "https://getpocket.com/v3/oauth/request")!
    public static let authorizeUrl = URL(string: "https://getpocket.com/v3/oauth/authorize")!

    private struct ObtainRequestTokenResponse: Decodable {

        let code: String

    }

    private struct ObtainAccessTokenResponse: Decodable {

        private enum CodingKeys: String, CodingKey {

            case accessToken = "access_token"
            case username

        }

        let accessToken: String
        let username: String

    }

}

// MARK: - Functions

extension Pocket {

    public func obtainRequestToken(forRedirectingTo redirectUrl: URL) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            obtainRequestToken(forRedirectingTo: redirectUrl, completion: continuation.resume)
        }
    }

    public func obtainRequestToken(forRedirectingTo redirectUrl: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let data = [
            "consumer_key": consumerKey,
            "redirect_uri": redirectUrl.absoluteString
        ]

        request(url: Pocket.requestTokenUrl, jsonData: data) { (result: Result<ObtainRequestTokenResponse, Error>) in
            switch result {
            case .success(let response):
                return completion(.success(response.code))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }

    public func buildAuthorizationUrl(for requestToken: String, redirectingTo redirectUrl: URL) -> URL? {
        guard var requestUrlComponents = URLComponents(url: Pocket.authorizeUrl, resolvingAgainstBaseURL: true) else {
            return nil
        }

        requestUrlComponents.queryItems = [
            URLQueryItem(name: "request_token", value: requestToken),
            URLQueryItem(name: "redirect_uri", value: redirectUrl.absoluteString)
        ]
        return requestUrlComponents.url
    }

    public func obtainAccessToken(for requestToken: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            obtainAccessToken(for: requestToken, completion: continuation.resume)
        }
    }

    public func obtainAccessToken(for requestToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let data = [
            "consumer_key": consumerKey,
            "code": requestToken
        ]

        request(url: Pocket.authorizeUrl, jsonData: data) { (result: Result<ObtainAccessTokenResponse, Error>) in
            switch result {
            case .success(let response):
                self.accessToken = response.accessToken
                self.username = response.username
                return completion(.success(response.accessToken))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }

}
