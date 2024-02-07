//
//  SettingsOptionsViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 13/01/2024.
//

import SwiftUI

enum SettingsOptionsViewModel: Int, CaseIterable, Identifiable {
    case darkMode
    case offlineMode
    case privacy
    case notifications
    
    var title: String {
        switch self {
        case .darkMode:
            return String(localized: "Dark mode")
        case .offlineMode:
            return String(localized: "Offline mode")
        case .privacy:
            return String(localized: "Security")
        case .notifications:
            return String(localized: "Notifications")
        }
    }
    
    var imageName: String {
        switch self {
        case .darkMode:
            return "moon.circle.fill"
        case .offlineMode:
            return "network.slash"
        case .privacy:
            return "lock.circle.fill"
        case .notifications:
            return "bell.circle.fill"
        }
    }
    
    var imageBackgroundColor: Color {
        switch self {
        case .darkMode:
            return .black
        case .offlineMode:
            return .black
        case .privacy:
            return Color(.systemBlue)
        case .notifications:
            return Color(.systemPurple)
        }
    }
    
    var hasSpecialView: Bool {
        switch self {
        case .darkMode:
            return true
        case .offlineMode:
            return true
        default:
            return false
        }
    }
    
    var specialView: some View {
        switch self {
        case .darkMode:
            return AnyView(AppearanceChangeView())
        case .offlineMode:
            return AnyView(NetworkStateView())
        default:
            return AnyView(EmptyView())
        }
    }
    
    var id: Int {return self.rawValue}
}
