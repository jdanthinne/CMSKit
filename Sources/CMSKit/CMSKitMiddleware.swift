//
//  FormsMiddleware.swift
//  App
//
//  Created by Jérôme Danthinne on 02/12/2019.
//

import Crypto
import Vapor

public final class CMSKitMiddleware: Middleware, Service {
    /// Create a new `CMSKitMiddleware`.
    public init() {}

    struct TokenContext: Decodable {
        let csrfToken: String
    }

    /// See `Middleware`.
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let session = try request.session()

        // If no token, generate a new one.
        if session["CSRF_TOKEN"] == nil {
            session["CSRF_TOKEN"] = try CryptoRandom().generateData(count: 64).base64EncodedString()
        }

        // If we're not handling a posted form, return.
        guard request.http.method == .POST,
            let contentType = request.http.headers.firstValue(name: .contentType),
            contentType == "application/x-www-form-urlencoded"
        else {
            return try next.respond(to: request)
        }

        // Validate the token.
        return try request.content
            .decode(TokenContext.self)
            .flatMap(to: Response.self) { context -> EventLoopFuture<Response> in
                guard context.csrfToken == session["CSRF_TOKEN"] else {
                    throw Abort(.forbidden)
                }
                return try next.respond(to: request)
            }
    }
}
