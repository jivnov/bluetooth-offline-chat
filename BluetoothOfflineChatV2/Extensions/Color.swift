//
//  Color.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 05/02/2024.
//

import Foundation
import SwiftUI

enum ColorSchemeMode: String {
    case off = "Off"
    case on = "On"
    case system = "System"
}

extension ColorScheme {
    static func getColorScheme(with scheme: String) -> ColorScheme? {
        if scheme == ColorSchemeMode.on.rawValue {
            return .dark
        } else if scheme == ColorSchemeMode.off.rawValue {
            return .light
        } else {
            return nil
        }
    }
}
