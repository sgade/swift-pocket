//
//  WebServer.swift
//  Pocket
//
//  Created by Sören Gade on 30.10.21.
//


import Swifter
import Darwin
import Foundation


class WebServer {

    private let server: HttpServer
    private let port: UInt16

    private let waitSemaphore = DispatchSemaphore(value: 0)

    init(on port: UInt16, at path: String) {
        self.port = port

        server = HttpServer()
        server[path] = { request in
            self.waitSemaphore.signal()

            return HttpResponse.ok(.text("Login successful. You may now close this website."))
        }
    }

    func start() throws {
        try server.start(port, forceIPv4: false, priority: .background)
    }

    func waitForCallback() {
        waitSemaphore.wait()
    }

    func stop() {
        server.stop()
    }

}
