//
//  CMSKit.swift
//  App
//
//  Created by Jérôme Danthinne on 05/12/2019.
//

import Leaf
import Vapor

public struct CMSKit {
    enum FieldRowIndex {
        case label, name, isRequired, value, formValues, errors, styling
    }

    typealias FieldRowIndexes = [FieldRowIndex: Int]

    enum Styling: String {
        case vertical, horizontal
    }

    enum LabelPosition {
        case before, after
    }

    typealias RowBuilder = (_ name: String, _ classes: String, _ value: String) -> String

    static func fieldRow(tag: TagContext,
                         indexes: FieldRowIndexes,
                         labelPosition: LabelPosition = .before,
                         labelClasses: String = "col-form-label form-control-label",
                         value: String? = nil,
                         fieldWrapper: (() -> (before: String, after: String))? = nil,
                         builder: RowBuilder) throws -> String {
        // Get required values
        guard let labelIndex = indexes[.label],
            let nameIndex = indexes[.name],
            let isRequiredIndex = indexes[.isRequired],
            let label = tag.parameters[labelIndex].string,
            let name = tag.parameters[nameIndex].string,
            let isRequired = tag.parameters[isRequiredIndex].bool else {
            throw Abort(.internalServerError, reason: "Unable to get Tag required parameters")
        }

        // Get the value and validation error for the field.
        let value = fieldValue(tag: tag, fieldName: name, valueIndex: indexes[.value], formValuesIndex: indexes[.formValues])
        let error = validationError(tag: tag, fieldName: name, errorsIndex: indexes[.errors])

        // Get the classes.
        let classes = error != nil ? "is-invalid" : ""

        // Get style.
        let style = styling(tag: tag, styleIndex: indexes[.styling])

        // Get field wrapper.
        let fieldWrapper = fieldWrapper?()

        // Generate label.
        var labelHTML = #"<label for="\#(name)" class="\#(labelClasses) \#(style == .horizontal && labelPosition == .before ? "col-sm-2" : "")">\#(label)"#
        if isRequired {
            labelHTML += #"<span class="text-danger">*</span>"#
        }
        labelHTML += #"</label>"#

        // Generate HTML.
        var html = #"<div class="form-group \#(style == .horizontal ? "row" : "")">"#

        if labelPosition == .before {
            html += labelHTML
        } else if style == .horizontal {
            html += #"<div class="col-sm-2"></div>"#
        }

        if style == .horizontal {
            html += #"<div class="col-sm-10">"#
        }

        if let beforeField = fieldWrapper?.before {
            html += beforeField
        }

        html += builder(name, classes, value)

        if labelPosition == .after {
            html += labelHTML
        }

        if let afterField = fieldWrapper?.after {
            html += afterField
        }

        if let error = error {
            html += #"<small class="form-text text-danger">\#(error)</small>"#
        }

        if style == .horizontal {
            html += #"</div>"#
        }

        html += #"</div>"#

        return html
    }

    // MARK: - Options getters

    private static func styling(tag: TagContext, styleIndex index: Int?) -> Styling {
        guard let index = index,
            index < tag.parameters.count,
            let parameter = tag.parameters[index].string,
            let styling = Styling(rawValue: parameter)
        else { return .horizontal }

        return styling
    }

    private static func fieldValue(tag: TagContext, fieldName: String, valueIndex: Int?, formValuesIndex: Int?) -> String {
        guard let formValuesIndex = formValuesIndex,
            formValuesIndex < tag.parameters.count
        else { return "" }

        guard let formValue = tag.parameters[formValuesIndex].dictionary?[fieldName]?.string else {
            guard let valueIndex = valueIndex else { return "" }
            return tag.parameters[valueIndex].string ?? ""
        }

        return formValue
    }

    private static func validationError(tag: TagContext, fieldName: String, errorsIndex index: Int?) -> String? {
        guard let index = index,
            index < tag.parameters.count,
            let errors = tag.parameters[index].dictionary
        else { return nil }

        return errors[fieldName]?.string
    }
}
