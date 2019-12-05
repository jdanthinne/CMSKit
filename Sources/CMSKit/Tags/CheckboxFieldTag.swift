//
//  CheckboxFieldTag.swift
//  App
//
//  Created by Jérôme Danthinne on 05/12/2019.
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
///     - style: String, "vertical" or "horizontal" (default)
public final class CheckboxFieldTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireNoBody()

        // Build HTML
        let indexes: CMSKit.FieldRowIndexes = [.label: 0,
                                               .name: 1,
                                               .isRequired: 2,
                                               .value: 3,
                                               .formValues: 4,
                                               .errors: 5,
                                               .styling: 6]

        let field = try CMSKit.fieldRow(tag: tag, indexes: indexes, labelPosition: .after) { name, classes, value in
            #"<input type="checkbox" name="\#(name)" id="\#(name)" class="form-check-input \#(classes)" value="\#(value)"/>"#
        }

        return Future.map(on: tag) {
            .string(field)
        }
    }
}
