//
//  Errors.swift
//  Pocket
//
//  Created by Sören Gade on 28.10.21.
//


import Foundation


extension Pocket {

    public enum Errors: Error {

        case invalid(value: Any, parameter: String)
        case notAuthenticated
        case unsuccessfulResponse
        case network(Error)

        /// General http error response.
        case errorResponse(status: Int, code: Int, message: String)

        /// Invalid request, please make sure you follow the documentation for proper syntax.
        ///
        /// HTTP 400
        case invalidRequest(code: Int, message: String)

        /// Problem authenticating the user.
        ///
        /// HTTP 401
        case authenticationFailed(code: Int, message: String)

        /// User was authenticated, but access denied due to lack of permission or rate limiting.
        ///
        /// HTTP 403
        case lackingPermission(code: Int, message: String)

        /// Pocket's sync server is down for scheduled maintenance.
        ///
        /// HTTP 503
        case serverDownForMaintenance

    }

}
