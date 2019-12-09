//
//  CMSKitProvider.swift
//
//
//  Created by Jérôme Danthinne on 09/12/2019.
//

import Vapor

public final class CMSKitProvider: Provider {
    public init() {}

    public func register(_ services: inout Services) throws {
        services.register(CMSKitMiddleware.self)
        services.register { container in
            CMSKitContainer()
        }
    }

    public func didBoot(_ container: Container) throws -> Future<Void> {
        .done(on: container)
    }
}
