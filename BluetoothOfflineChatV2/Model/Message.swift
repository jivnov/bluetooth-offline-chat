//
//  Message.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 26/01/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable, Hashable {
    @DocumentID var messageId: String?
    let fromId: String
    let toId: String
    let messageText: String
    let timestamp: Timestamp
    let unread: Bool
    let isUnsend: Bool
    
    var user: User?
    
    var id: String {
        return messageId ?? UUID().uuidString
    }
    
    var chatPartnerId: String {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    var isFromCurrentUser: Bool {
        return fromId == Auth.auth().currentUser?.uid
    }
    
    var timestampString: String {
        return timestamp.dateValue().timestampString()
    }
    
    var timestampFullString: String {
        return timestamp.dateValue().timestampFullString()
    }
    
    var encodedToSendOffline: [String: String] {
        let stringTime = timestamp.dateValue().timestampDateToString()
        return ["messageId": id,
              "messageText": messageText,
              "timestamp": stringTime]
    }
}
