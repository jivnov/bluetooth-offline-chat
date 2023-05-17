//
//  BiometricHelper.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 17/05/2023.
//

import Foundation
import LocalAuthentication

class BiometricHelper {
    let context = LAContext()
    var error: NSError?
    
    func isBiometricAvailable() -> Bool {
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return true
        }
        return false
    }
    
    func isBiometricEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "biometricEnabled")
    }
    
    func setBiometricEnabled(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "biometricEnabled")
    }
}

