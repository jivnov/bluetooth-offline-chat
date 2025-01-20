//
//  SecurityService.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 19/01/2025.
//

import Foundation
import LocalAuthentication

struct SecurityService {
    private static let keychainKey = "boc-passcode"
    private static let biometricSwitchKey = "boc-biometric-switch-state"
    
    static func savePasscode(_ passcode: String) {
        let data = Data(passcode.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func retrievePasscode() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard status == errSecSuccess, let data = dataTypeRef as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    static func deletePasscode() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    static func setBiometricState(isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: biometricSwitchKey)
    }
    
    static func isBiometricEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: biometricSwitchKey)
    }
    
    static func canUseBiometricAuthentication() -> String? {
        let context = LAContext()
        var error: NSError?
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return error?.localizedDescription
    }
    
    static func getBiometricType() -> String? {
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else { return nil}
        switch context.biometryType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        default:
            return nil
        }
    }
    
    static func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        let reason = String(localized: "Use biometric to access app data.")
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            
            throw error ?? NSError(domain: "Unknown error", code: -10)
        }
        
        return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
    }
}
