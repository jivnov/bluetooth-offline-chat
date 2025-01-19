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
    
    static func authenticateWithBiometrics(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?
        let reason = "Authenticate to access your passcode"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                DispatchQueue.main.async {
                    completion(success, evaluateError)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false, error)
            }
        }
    }
}
