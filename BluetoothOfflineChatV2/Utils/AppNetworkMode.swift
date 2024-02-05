//
//  AppNetworkMode.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 27/01/2024.
//

import Foundation
import Firebase

enum AppNetworkMode {
    case online
    case offline
        
    static func getAppMode() -> AppNetworkMode {
        return UserDefaults.standard.bool(forKey: "offline_mode_enabled") ? .offline : .online
    }
    
    static func offlineModeEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "offline_mode_enabled")
    }
    
    static func setAppMode(_ mode: AppNetworkMode) {
        switch mode {
        case .online:
            UserDefaults.standard.set(false, forKey: "offline_mode_enabled")
        case .offline:
            UserDefaults.standard.set(true, forKey: "offline_mode_enabled")
        }
    }
    
    static func changeNetworkState(isOn: Bool) {
        if isOn {
            AppNetworkMode.setAppMode(.offline)
            Firestore.firestore().disableNetwork()
            ChatConnectivity.shared.startConnectivity()
        }
        else {
            AppNetworkMode.setAppMode(.online)
            Firestore.firestore().enableNetwork()
            ChatConnectivity.shared.stopConnectivity()
        }
    }
}
