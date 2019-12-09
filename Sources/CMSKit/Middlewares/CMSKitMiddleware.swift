//
//  FormsMiddleware.swift
//  App
//
//  Created by Jérôme Danthinne on 02/12/2019.
//

import Crypto
import Vapor

public final class CMSKitMiddleware: Middleware, ServiceType {
    private static let sessionKey = "_cmskit"

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    struct TokenContext: Decodable {
        let csrfToken: String?
    }

    public init() {}

    public static func makeService(for container: Container) throws -> Self {
        .init()
    }

    /// See `Middleware`.
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        try handle(req: request)
        return try next.respond(to: request)
            .flatMap { resp in
                try request.content
                    .decode(TokenContext.self)
                    .map(to: Response.self) { context in
                        let container = try self.handle(req: request, resp: resp)

                        // If we're not handling a posted form, return.
                        guard request.http.method == .POST,
                            let contentType = request.http.headers.firstValue(name: .contentType),
                            contentType == "application/x-www-form-urlencoded"
                        else {
                            return resp
                        }

                        // Validate the token.
                        guard context.csrfToken == container.csrfToken else {
                            throw Abort(.forbidden)
                        }

                        return resp
                    }
            }
    }

    private func handle(req: Request) throws {
        guard let data = try req.session()[Self.sessionKey]?.data(using: .utf8) else { return }

        let cmskitUserInfo = try jsonDecoder.decode(CMSKitContainer.self,
                                                    from: data)
        let container = try req.privateContainer.make(CMSKitContainer.self)

        // If no token, generate a new one.
        container.csrfToken = try cmskitUserInfo.csrfToken
            ?? CryptoRandom().generateData(count: 64).base64EncodedString()

        container.formValues = cmskitUserInfo.formValues
        container.infoMessages = cmskitUserInfo.infoMessages
        container.validationErrors = cmskitUserInfo.formValues
    }

    private func handle(req: Request, resp: Response) throws -> CMSKitContainer {
        let container = try req.privateContainer.make(CMSKitContainer.self)
        let cmskitUserInfo = try String(data: jsonEncoder.encode(container),
                                        encoding: .utf8)
        try req.session()[Self.sessionKey] = cmskitUserInfo

        return container
    }
}
