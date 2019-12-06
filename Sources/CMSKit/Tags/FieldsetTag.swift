//
//  FieldsetTag.swift
//  App
//
//  Created by Jérôme Danthinne on 04/12/2019.
//

import Vapor

/// Renders a fieldset
/// - Parameters:
///     - legend: String
public final class FieldsetTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        let body = try tag.requireBody()

        guard let legend = tag.parameter(at: 1)?.string
        else { throw Abort(.internalServerError, reason: "Unable to get Tag required parameters") }

        // Build HTML
        return tag.serializer.serialize(ast: body).map(to: TemplateData.self) { body in
            .string("""
                <fieldset class="form-group">
                    <legend>\(legend)</legend>
                    \(body)
                </fieldset>
            """)
        }
    }
}
