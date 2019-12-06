//
//  SelectFieldTag.swift
//  App
//
//  Created by Jérôme Danthinne on 03/12/2019.
//

import Vapor

/// Renders a select field
/// - Parameters:
///     - label: String
///     - name: String
///     - isRequired: Bool (default to false)
///     - options: [Option]
///     - value: String, initial field value
///     - formValues: [String: String], array of submitted form values
///     - validationErrors: [String: String], array of form validation errors
///     - style: String, "vertical" or "horizontal" (default)
public final class SelectFieldTag: TagRenderer {
    public struct Option: Encodable {
        let label: String
        let value: String

        public init<T>(_ option: T) where T: RawRepresentable, T: CustomStringConvertible {
            label = option.description
            value = String(describing: option.rawValue)
        }

        init?(data: TemplateData) {
            guard let label = data.dictionary?["label"]?.string,
                let value = data.dictionary?["value"]?.string
            else { return nil }

            self.label = label
            self.value = value
        }
    }

    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireNoBody()

        // Get required values.
        guard let label = tag.parameter(at: 0)?.string,
            let name = tag.parameter(at: 1)?.string,
            let isRequired = tag.parameter(at: 2)?.bool,
            let selectOptions = tag.parameter(at: 3)?.array
        else {
            throw Abort(.internalServerError, reason: "Unable to get Tag required parameters")
        }

        // Build HTML
        let indexes: CMSKit.FieldRowIndexes = [.value: 4,
                                               .formValues: 5,
                                               .errors: 6,
                                               .styling: 7]

        let field = tag.fieldRow(indexes: indexes) { options in
            // Label
            var html = #"<label for="\#(name)" class="col-form-label form-control-label \#(options.styling == .horizontal ? "col-sm-2" : "")">\#(label)\#(isRequired ? #"<span class="text-danger">*</span>"# : "")</label>"#

            // Select
            if options.styling == .horizontal {
                html += #"<div class="col-sm-10">"#
            }

            html += #"<select name="\#(name)" id="\#(name)" class="form-control \#(options.classes)"/>"#

            for selectOption in selectOptions.compactMap(Option.init) {
                html += #"<option value="\#(selectOption.value)""#
                if selectOption.value == options.value {
                    html += #" selected="selected""#
                }
                html += ">\(selectOption.label)</option>"
            }

            html += "</select>"

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
