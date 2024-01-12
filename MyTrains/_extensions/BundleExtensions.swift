//
//  BundleExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation
import UniformTypeIdentifiers

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "v\(releaseVersionNumber ?? "1.0.0")"
    }
}

extension UTType {
  public static let dmf = UTType(importedAs: "dmf")
  public static let csv = UTType(importedAs: "csv")
}

