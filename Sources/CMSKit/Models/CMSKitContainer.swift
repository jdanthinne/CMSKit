//
//  CMSKitContainer.swift
//
//
//  Created by Jérôme Danthinne on 09/12/2019.
//

import Vapor

public final class CMSKitContainer: Codable, Service {
    var csrfToken: String? = nil
    var formValues: [String: String] = [:]
    var infoMessages: [CMSKitInfoMessage] = []
    var validationErrors: [String: String] = [:]
}
