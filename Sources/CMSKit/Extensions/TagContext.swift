//
//  TagContext.swift
//
//
//  Created by Jérôme Danthinne on 09/12/2019.
//

import Leaf
import Vapor

extension TagContext {
    public func requireRequest() throws -> Request {
        guard let request = container as? Request
        else { throw Abort(.internalServerError) }

        return request
    }

    public func requireCMSKit() throws -> CMSKitContainer {
        try requireRequest().privateContainer.make()
    }
}
