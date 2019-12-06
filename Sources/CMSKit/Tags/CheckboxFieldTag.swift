//
//  CheckboxFieldTag.swift
//  App
//
//  Created by Jérôme Danthinne on 05/12/2019.
//

import Vapor

/// Renders a checkbox field
/// - Parameters:
///     - label: String
///     - name: String
///     - isRequired: Bool (default to false)
///     - value: String, initial field value
///     - formValues: [String: String], array of submitted form values
///     - validationErrors: [String: String], array of form validation errors
///     - style: String, "vertical" or "horizontal" (default)
public final class CheckboxFieldTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireNoBody()

        // Get required values.
        guard let label = tag.parameter(at: 0)?.string,
            let name = tag.parameter(at: 1)?.string,
            let isRequired = tag.parameter(at: 2)?.bool
        else {
            throw Abort(.internalServerError, reason: "Unable to get Tag required parameters")
        }

        // Build HTML
        let indexes: CMSKit.FieldRowIndexes = [.value: 3,
                                               .formValues: 4,
                                               .errors: 5,
                                               .styling: 6]

        let field = tag.fieldRow(indexes: indexes) { options in
            var html = ""

            // Input
            if options.styling == .horizontal {
                html += #"<div class="col-sm-2"></div><div class="col-sm-10">"#
            }

            html += """
                <div class="form-check">
                    <input type="checkbox" name="\(name)" id="\(name)" class="form-check-input \(options.classes)" value="1" \(options.value == "1" ? #"checked="checked"# : "")/>
                    <label for="\(name)" class="form-check-label">\(label)\(isRequired ? #"<span class="text-danger">*</span>"# : "")</label>
                </div>
            """

            // Error
            if let error = options.error {
                html += #"<small class="form-text text-danger">\#(error)</small>"#
            }

            if options.styling == .horizontal {
                html += "</div>"
            }

            return html
        }

        return Future.map(on: tag) {
            .string(field)
        }
    }
}
