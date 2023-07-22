//
//  Pocket+Authentication.swift
//  Pocket
//
//  Created by Sören Gade on 28.10.21.
//


import Foundation

// MARK: Serialization data structures

extension Pocket {

    public static let requestTokenUrl = URL(string: "https://getpocket.com/v3/oauth/request")!
    public static let authorizeUrl = URL(string: "https://getpocket.com/v3/auth/authorize")!
    public static let accessTokenUrl = URL(string: "https://getpocket.com/v3/oauth/authorize")!

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
        let data = [
            "consumer_key": consumerKey,
            "redirect_uri": redirectUrl.absoluteString
        ]

        let response: ObtainRequestTokenResponse = try await request(url: Pocket.requestTokenUrl, jsonData: data)
        return response.code
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
        let data = [
            "consumer_key": consumerKey,
            "code": requestToken
        ]

        let response: ObtainAccessTokenResponse = try await request(url: Pocket.accessTokenUrl, jsonData: data)
        accessToken = response.accessToken
        username = response.username
        return response.accessToken
    }

}
