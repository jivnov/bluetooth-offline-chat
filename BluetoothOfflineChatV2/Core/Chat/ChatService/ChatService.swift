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
            ChatConnectivity.shared.send(message: message.encodedToSendOffline, to: chatPartnerId)
        }
    }
    
    static func getOfflineMessage(from chatPartnerId: String?, messageData: [String : String]) {
        guard let currentUid = Auth.auth().currentUser?.uid,
                let chatPartnerId = chatPartnerId,
                let messageId = messageData["messageId"],
                let messageText = messageData["messageText"]
        else { return }
        
        var timestamp: Timestamp
        if let messageTime = messageData["timestamp"], let time = Date().timestampDate(from: messageTime) {
            timestamp = Timestamp(date: time)
        }
        else {
            timestamp = Timestamp()
        }
            
        let currentUserRef = FirestoreConstans.MessagesCollection
            .document(currentUid)
            .collection(chatPartnerId).document(messageId)
        
        let messageDocId = currentUserRef.documentID
        
        let message = Message(
            messageId: messageDocId,
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
