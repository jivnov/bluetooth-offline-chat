//
//  User.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 20/01/2024.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable, Hashable {
    @DocumentID var uid: String?
    let fullName: String
    let email: String
    var profileImageUrl: String?
    
    var id: String {
        return uid ?? NSUUID().uuidString
    }
    
    var firstName: String {
        let formatter = PersonNameComponentsFormatter()
        let components = formatter.personNameComponents(from: fullName)
        return components?.givenName ?? fullName
    }
    
    var initialsFromName: String {
        let components = fullName.split(separator: " ")
        var result = ""
        for component in components {
            result += String(component.first!)
            result += " "
        }
        return result.capitalized
    }
}

extension User {
    static let MOCK_USER = User(fullName: "Mock Name", email: "email@mail.com")
}
