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
///     - style: String, "vertical" or "horizontal" (default)
public final class FieldsetTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        let body = try tag.requireBody()

        guard let legend = tag.parameter(at: 0)?.string
        else { throw Abort(.internalServerError, reason: "Unable to get Tag required parameters") }

        // Get style.
        let styling = tag.fieldStyling(parameterIndex: 1)

        // Build HTML
        return tag.serializer.serialize(ast: body).map(to: TemplateData.self) { body in
            let body = String(data: body.data, encoding: .utf8) ?? ""

            var html = """
            <fieldset class="form-group">
                <legend class="d-none">\(legend)</legend>
            """

            if styling == .horizontal {
                html += """
                <div class="form-group row">
                    <div class="col-sm-2"></div>
                    <div class="col-sm-10">
                """
            }

            html += #"<h3>\#(legend)</h3>"#

            if styling == .horizontal {
                html += """
                    </div>
                    <div class="col-sm-12"><hr></div>
                </div>
                """
            } else {
                html += "<hr>"
            }

            html += """
                \(body)
            </fieldset>
            """

            return .string(html)
        }
    }
}
