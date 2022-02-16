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

        let access_token: String
        let username: String

    }

}

// MARK: - Functions

extension Pocket {

    private func obtainRequestToken(using redirectUrl: URL) throws -> String {
        let data = [
            "consumer_key": consumerKey,
            "redirect_uri": redirectUrl.absoluteString
        ]
        let url = URL(string: "https://getpocket.com/v3/oauth/request")!
        let response: ObtainRequestTokenResponse = try request(url: url, jsonData: data)

        return response.code
    }

    public func obtainAccessToken(using redirectUrl: URL) throws {
        let requestToken = try obtainRequestToken(using: redirectUrl)

        var requestUrlComponents = URLComponents(string: "https://getpocket.com/auth/authorize")!
        requestUrlComponents.queryItems = [
            URLQueryItem(name: "request_token", value: requestToken),
            URLQueryItem(name: "redirect_uri", value: redirectUrl.absoluteString)
        ]
        let requestUrl = requestUrlComponents.url!

        let redirectUrlComponents = URLComponents(url: redirectUrl, resolvingAgainstBaseURL: false)!
        let webServer = WebServer(on: UInt16(redirectUrlComponents.port ?? 0), at: redirectUrlComponents.path)
        try webServer.start()
        print("Please open URL \(requestUrl.absoluteString) and login.")
        webServer.waitForCallback()

        let authorizeUrl = URL(string: "https://getpocket.com/v3/oauth/authorize")!
        let data = [
            "consumer_key": consumerKey,
            "code": requestToken
        ]
        let authorizeResponse: ObtainAccessTokenResponse = try request(url: authorizeUrl, jsonData: data)
        accessToken = authorizeResponse.access_token
        username = authorizeResponse.username
    }

}
