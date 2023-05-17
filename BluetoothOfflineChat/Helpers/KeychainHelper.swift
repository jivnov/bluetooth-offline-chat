//
//  KeychainHelper.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 17/05/2023.
//

import Foundation
import AuthenticationServices

class KeychainHelper {
    
    func addNewPassword(_ pass: String) {
        let password = pass.data(using: String.Encoding.utf8)!
        
        let query = [
            kSecValueData as String: password,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "BluetoothOfflineChat"
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        if status != errSecSuccess {
            print("Error addNewPassword: \(status)")
        }
    }
    
    func updatePassword(_ pass: String) {
        let password = pass.data(using: String.Encoding.utf8)!
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "BluetoothOfflineChat"
        ] as CFDictionary
        
        let updatedData = [kSecValueData as String: password] as CFDictionary
        
        let status = SecItemUpdate(query, updatedData)
        if status != errSecSuccess {
            print("Error updatePassword: \(status)")
        }
    }
    
    func getPassword() -> String {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "BluetoothOfflineChat",
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        if status != errSecSuccess {
            print("Error getPassword: \(status)")
        }
        
        return String(decoding: result as! Data, as: UTF8.self)
    }
    
    func removePassword() {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "BluetoothOfflineChat"
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        if status != errSecSuccess {
            print("Error removePassword: \(status)")
        }
    }
}
