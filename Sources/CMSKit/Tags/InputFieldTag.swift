//
//  InputFieldTag.swift
//  App
//
//  Created by Jérôme Danthinne on 03/12/2019.
//

import Vapor

/// Renders a form tag, including a CSRF Token
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

        // Get input type.
        let inputType: InputType
        if tag.parameters.count >= 7,
            let type = InputType(rawValue: tag.parameters[6].string ?? "") {
            inputType = type
        } else {
            inputType = .text
        }

        // Build HTML
        let indexes: CMSKit.FieldRowIndexes = [.label: 0,
                                               .name: 1,
                                               .isRequired: 2,
                                               .value: 3,
                                               .formValues: 4,
                                               .errors: 5,
                                               .styling: 7]

        let field = try CMSKit.fieldRow(tag: tag, indexes: indexes) { name, classes, value in
            #"<input type="\#(inputType)" name="\#(name)" id="\#(name)" class="form-control \#(classes)" value="\#(value)"/>"#
        }

        return Future.map(on: tag) {
            .string(field)
        }
    }
}
