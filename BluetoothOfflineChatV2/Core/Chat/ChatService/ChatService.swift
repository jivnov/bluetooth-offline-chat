//
//  ChatService.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 26/01/2024.
//

import Foundation
import Firebase

struct ChatService {
    let chatPartner: User
    
    func sendMessage(_ messageText: String) {
        let offlineModeEnabled = AppNetworkMode.offlineModeEnabled()
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        let currentUserRef = FirestoreConstans.MessagesCollection
            .document(currentUid)
            .collection(chatPartnerId).document()
        
        let chatPartnerRef = FirestoreConstans.MessagesCollection
            .document(chatPartnerId)
            .collection(currentUid)
        
        let recentCurrentUserRef = FirestoreConstans.MessagesCollection
            .document(currentUid)
            .collection("recent-messages")
            .document(chatPartnerId)
        
        let recentPartnertUserRef = FirestoreConstans.MessagesCollection
            .document(chatPartnerId)
            .collection("recent-messages")
            .document(currentUid)
        
        let messageId = currentUserRef.documentID
        
        let message = Message(
            messageId: messageId,
            fromId: currentUid,
            toId: chatPartnerId,
            messageText: messageText,
            timestamp: Timestamp()
        )
        
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        currentUserRef.setData(messageData)
        chatPartnerRef.document(messageId).setData(messageData)
        
        recentCurrentUserRef.setData(messageData)
        recentPartnertUserRef.setData(messageData)
        
        if offlineModeEnabled {
            let stringTime = message.timestamp.dateValue().timestampDateToString()
            let dataToSend = ["messageId": messageId,
                              "messageText": messageText,
                              "timestamp": stringTime]
            ChatConnectivity.shared.send(message: dataToSend, to: chatPartnerId)
        }
    }
    
    static func getOfflineMessage(from chatPartnerId: String, messageText: String, messageId: String, messageTime: String) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let time = Date().timestampDate(from: messageTime)
        let timestamp = time != nil ? Timestamp(date: time!) : Timestamp()
        
        let currentUserRef = FirestoreConstans.MessagesCollection
            .document(currentUid)
            .collection(chatPartnerId).document(messageId)
        
        let messageId1 = currentUserRef.documentID
        
        let message = Message(
            messageId: messageId1,
            fromId: chatPartnerId,
            toId: currentUid,
            messageText: messageText,
            timestamp: timestamp
        )
        
        let chatPartnerRef = FirestoreConstans.MessagesCollection
            .document(chatPartnerId)
            .collection(currentUid)
        
        let recentCurrentUserRef = FirestoreConstans.MessagesCollection
            .document(currentUid)
            .collection("recent-messages")
            .document(chatPartnerId)
        
        let recentPartnertUserRef = FirestoreConstans.MessagesCollection
            .document(chatPartnerId)
            .collection("recent-messages")
            .document(currentUid)
        
        
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }

        currentUserRef.setData(messageData)
        chatPartnerRef.document(messageId).setData(messageData)
        
        recentCurrentUserRef.setData(messageData)
        recentPartnertUserRef.setData(messageData)
    }
    
    func observeMessages(completion: @escaping([Message]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        let query = FirestoreConstans.MessagesCollection
            .document(currentUid)
            .collection(chatPartnerId)
            .order(by: "timestamp", descending: false)
        
        query.addSnapshotListener {snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            var messages = changes.compactMap({ try? $0.document.data(as: Message.self) })
            
            for (index, message) in messages.enumerated() where message.fromId != currentUid {
                messages[index].user = chatPartner
            }
            
            completion(messages)
        }
    }
}
