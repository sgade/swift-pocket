//
//  OAth.swift
//  Pocket
//
//  Created by Sören Gade on 28.10.21.
//


import Foundation

// MARK: - Serialization data structures

extension Pocket {

    private struct ObtainRequestTokenResponse: Decodable {

        let code: String

    }

    private struct ObtainAccessTokenResponse: Decodable {

        public enum CodingKeys: String, CodingKey {

            case accessToken = "access_token"
            case username

        }

        let accessToken: String
        let username: String

    }

}

// MARK: - Functions

extension Pocket {

    public func obtainRequestToken(forRedirectingTo redirectUrl: URL) throws -> String {
        let data = [
            "consumer_key": consumerKey,
            "redirect_uri": redirectUrl.absoluteString
        ]
        let url = URL(string: "https://getpocket.com/v3/oauth/request")!
        let response: ObtainRequestTokenResponse = try request(url: url, jsonData: data)

        return response.code
    }

    public func buildAuthorizationUrl(for requestToken: String, redirectingTo redirectUrl: URL) -> URL {
        var requestUrlComponents = URLComponents(string: "https://getpocket.com/auth/authorize")!
        requestUrlComponents.queryItems = [
            URLQueryItem(name: "request_token", value: requestToken),
            URLQueryItem(name: "redirect_uri", value: redirectUrl.absoluteString)
        ]
        return requestUrlComponents.url!
    }

    @discardableResult
    public func obtainAccessToken(for requestToken: String) throws -> String {
        let authorizeUrl = URL(string: "https://getpocket.com/v3/oauth/authorize")!
        let data = [
            "consumer_key": consumerKey,
            "code": requestToken
        ]

        let authorizeResponse: ObtainAccessTokenResponse = try request(url: authorizeUrl, jsonData: data)
        accessToken = authorizeResponse.accessToken
        username = authorizeResponse.username

        return authorizeResponse.accessToken
    }

}
