//
//  FormTag.swift
//  App
//
//  Created by Jérôme Danthinne on 04/12/2019.
//

import Vapor

/// Renders a form tag, including a CSRF Token
/// - Parameters:
///     - action: destination url
///     - classes: classes for the form tag
///     - objectId: Id of object being edited
///     - basePath: base path for cancelling or deleting object
public final class FormTag: TagRenderer {
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        let body = try tag.requireBody()

        guard let request = tag.container as? Request
        else { throw Abort(.internalServerError) }

        // Get form action.
        let action: String
        if tag.parameters.count >= 1,
            let formAction = tag.parameters[0].string,
            !formAction.isEmpty {
            action = formAction
        } else {
            action = request.http.urlString
        }

        print(request.http)

        // Get form classes.
        let classes: String
        if tag.parameters.count >= 2 {
            classes = tag.parameters[1].string ?? ""
        } else {
            classes = ""
        }

        // Build HTML
        return tag.serializer.serialize(ast: body).map(to: TemplateData.self) { body in
            var html = #"<form action="\#(action)" class="\#(classes)" method="POST">"#
            html += String(data: body.data, encoding: .utf8) ?? ""

            // If an object is provided, include footer buttons.
            if tag.parameters.count >= 3 {
                html += """
                    <hr>
                    <div class="form-group row">
                    <div class="col-sm-2"></div>
                    <div class="col-sm-10 d-flex justify-content-between">
                        <div>
                """

                // Submit depends on creation or editing.
                let submitTitle = tag.parameters[2].isNull ? "Enregistrer" : "Enregistrer les modifications"
                html += #"<button type="submit" class="btn-primary btn" name="save" value="save">\#(submitTitle)</button>"#

                // Cancel button.
                let basePath: String? = tag.parameters.count >= 4 ? tag.parameters[3].string : nil
                if let returnPath = basePath {
                    html += #"<a href="\#(returnPath)" class="btn btn-link">Annuler</a>"#
                }

                html += "</div>"

                // Delete button.
                if let objectId = tag.parameters[2].string,
                    let path = basePath {
                    html += #"<a href="\#(path)/\#(objectId)/delete" class="btn btn-danger">Supprimer</a>"#
                }

                html += "</div></div>"
            }

            // CSFR Token
            guard let token = try request.session()["CSRF_TOKEN"] else {
                throw Abort(.internalServerError, reason: "Unable to retrieve session token")
            }
            html += #"<input type="hidden" name="csrfToken" value="\#(token)">"#

            html += #"</form>"#

            return .string(html)
        }
    }
}
