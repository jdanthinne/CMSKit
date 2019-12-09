//
//  File.swift
//
//
//  Created by Jérôme Danthinne on 09/12/2019.
//

import Foundation

public struct CMSKitInfoMessage: Codable {
    enum Severity: String, Codable {
        case normal = "primary"
        case success
        case warning
        case error = "danger"
    }

    let message: String
    let severity: Severity

    init(_ message: String, severity: Severity) {
        self.message = message
        self.severity = severity
    }
}
