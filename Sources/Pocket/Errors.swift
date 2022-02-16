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
        case response(status: Int, code: Int, message: String)
        case serverDownForMaintenance

    }

}
