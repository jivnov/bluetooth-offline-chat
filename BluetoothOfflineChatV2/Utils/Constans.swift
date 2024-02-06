//
//  Constans.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 26/01/2024.
//

import Foundation
import Firebase
import SwiftUI

struct FirestoreConstans {
    static let UserCollection = Firestore.firestore().collection("users")
    static let MessagesCollection = Firestore.firestore().collection("messages")
}

struct ColorConstans {
    
    static let appDarkBlueColor = Color(red: 10/255, green: 61/255, blue: 145/255)
    static let appLightBlueColor = Color(red: 103/255, green: 179/255, blue: 249/255)
    
    static func getAppPrimalyBlueColor(darkMode enabled: Bool) -> Color {
        return enabled ? appLightBlueColor : appDarkBlueColor
    }
    
    static func getAppPrimalyGrayColor(darkMode enabled: Bool, baseColor: UIColor = .systemGray5) -> Color {
        return enabled ? Color(.darkGray) : Color(baseColor)
    }
}
