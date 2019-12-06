//
//  InputFieldTag.swift
//  App
//
//  Created by Jérôme Danthinne on 03/12/2019.
//

import Vapor

/// Renders an input field
/// - Parameters:
///     - label: String
///     - name: String
///     - isRequired: Bool (default to false)
///     - value: String, initial field value
///     - formValues: [String: String], array of submitted form values
///     - validationErrors: [String: String], array of form validation errors
///     - type: String, field type (default to "text")
///     - style: String, "vertical" or "horizontal" (default)
public final class InputFieldTag: TagRenderer {
    enum InputType: String {
        case text, password, email
    }

    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireNoBody()

        // Get required values.
        guard let label = tag.parameter(at: 0)?.string,
            let name = tag.parameter(at: 1)?.string,
            let isRequired = tag.parameter(at: 2)?.bool
        else {
            throw Abort(.internalServerError, reason: "Unable to get Tag required parameters")
        }

        // Get input type.
        let inputType: InputType
        if tag.parameters.count >= 7,
            let type = InputType(rawValue: tag.parameters[6].string ?? "") {
            inputType = type
        } else {
            inputType = .text
        }

        // Build HTML.
        let indexes: CMSKit.FieldRowIndexes = [.value: 3,
                                               .formValues: 4,
                                               .errors: 5,
                                               .styling: 7]

        let field = tag.fieldRow(indexes: indexes) { options in
            // Label
            var html = #"<label for="\#(name)" class="col-form-label form-control-label \#(options.styling == .horizontal ? "col-sm-2" : "")">\#(label)\#(isRequired ? #"<span class="text-danger">*</span>"# : "")</label>"#

            // Input
            if options.styling == .horizontal {
                html += #"<div class="col-sm-10">"#
            }

            html += #"<input type="\#(inputType)" name="\#(name)" id="\#(name)" class="form-control \#(options.classes)" value="\#(options.value?.string ?? "")"/>"#

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
