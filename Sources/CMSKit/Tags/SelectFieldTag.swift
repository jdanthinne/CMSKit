//
//  SelectFieldTag.swift
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
///     - options: [Option]
///     - value: String, initial field value
///     - formValues: [String: String], array of submitted form values
///     - validationErrors: [String: String], array of form validation errors
///     - style: String, "vertical" or "horizontal" (default)
public final class SelectFieldTag: TagRenderer {
    
    struct Option: Encodable {
        let label: String
        let value: String

        init<T>(_ option: T) where T: RawRepresentable, T: CustomStringConvertible {
            label = option.description
            value = String.init(describing: option.rawValue)
        }

        init?(data: TemplateData) {
            guard let label = data.dictionary?["label"]?.string,
            let value = data.dictionary?["value"]?.string
            else { return nil }

            self.label = label
            self.value = value
        }
    }
    
    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireNoBody()

        // Get required values
        guard let options = tag.parameters[3].array else {
            throw Abort(.internalServerError, reason: "Unable to get select tag options")
        }
        
        // Build HTML
        let indexes: CMSKit.FieldRowIndexes = [.label: 0,
                                               .name: 1,
                                               .isRequired: 2,
                                               .value: 4,
                                               .formValues: 5,
                                               .errors: 6,
                                               .styling: 7]
        
        let field = try CMSKit.fieldRow(tag: tag, indexes: indexes) { name, classes, value in
            var html = #"<select name="\#(name)" id="\#(name)" class="form-control \#(classes)"/>"#
            
            for option in options.compactMap(Option.init) {
                html += #"<option value="\#(option.value)""#
                if option.value == value {
                    html += #" selected="selected""#
                }
                html += #">\#(option.label)</option>"#
            }
            
            html += #"</select>"#
            
            return html
        }

        return Future.map(on: tag) {
            .string(field)
        }
    }
}
