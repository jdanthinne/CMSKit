//
//  CMSKit.swift
//  App
//
//  Created by Jérôme Danthinne on 05/12/2019.
//

import Leaf
import Vapor

extension TagContext {
    public func fieldRow(indexes: CMSKit.FieldRowIndexes,
                         builder: CMSKit.FieldRowBuilder) -> String {
        // Get the value and validation error for the field.
        let value = fieldValue(fieldName: name,
                               valueParameterIndex: indexes[.value],
                               formValuesParameterIndex: indexes[.formValues])
        let error = fieldError(fieldName: name,
                               parameterIndex: indexes[.errors])

        // Get the classes.
        let classes = error != nil ? "is-invalid" : ""

        // Get style.
        let styling = fieldStyling(parameterIndex: indexes[.styling])

        // Generate HTML.
        let options = CMSKit.FieldRowBuilderOptions(classes: classes,
                                                    value: value,
                                                    error: error,
                                                    styling: styling)

        return """
            <div class="form-group \(styling == .horizontal ? "row" : "")">
                \(builder(options))
            </div>
        """
    }

    func fieldStyling(parameterIndex: Int?) -> CMSKit.FieldRowStyling {
        guard let parameter = parameter(at: parameterIndex)?.string,
            let styling = CMSKit.FieldRowStyling(rawValue: parameter)
        else { return .horizontal }

        return styling
    }

    func fieldValue(fieldName: String, valueParameterIndex: Int?, formValuesParameterIndex: Int?) -> TemplateData? {
        guard let formValue = parameter(at: formValuesParameterIndex)?.dictionary?[fieldName] else {
            return parameter(at: valueParameterIndex)
        }

        return formValue
    }

    func fieldError(fieldName: String, parameterIndex: Int?) -> String? {
        guard let errors = parameter(at: parameterIndex)?.dictionary
        else { return nil }

        return errors[fieldName]?.string
    }

    func parameter(at index: Int?) -> TemplateData? {
        guard let index = index,
            index < parameters.count
        else { return nil }

        return parameters[index]
    }
}

public struct CMSKit {
    public enum FieldRowIndex {
        case value, formValues, errors, styling
    }

    public typealias FieldRowIndexes = [FieldRowIndex: Int]

    public enum FieldRowStyling: String {
        case vertical, horizontal
    }

    public struct FieldRowBuilderOptions {
        let classes: String
        let value: TemplateData?
        let error: String?
        let styling: FieldRowStyling
    }

    public typealias FieldRowBuilder = (_ options: FieldRowBuilderOptions) -> String
}
