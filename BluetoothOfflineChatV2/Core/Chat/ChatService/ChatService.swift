//
//  ChatService.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 26/01/2024.
//

import Foundation
import Firebase
import CommonCrypto

struct ChatService {
    let chatPartner: User
    
    func sendMessage(_ messageText: String) {
        let offlineModeEnabled = AppNetworkMode.offlineModeEnabled()
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
                
        let messagesRef = ChatService.getMessagesCollectionRef(for: currentUid, chatPartnerId).document()
        let recentRefs = ChatService.getRecentRef(for: currentUid, chatPartnerId)
        
        let messageId = messagesRef.documentID
        
        let message = Message(
            messageId: messageId,
            fromId: currentUid,
            toId: chatPartnerId,
            messageText: messageText,
            timestamp: Timestamp(),
            unread: true,
            isUnsend: false
        )
        
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        messagesRef.setData(messageData)
        recentRefs.forEach { $0.setData(messageData) }
        
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
        
        let messagesRef = ChatService.getMessagesCollectionRef(for: currentUid, chatPartnerId).document(messageId)
        let recentRefs = ChatService.getRecentRef(for: currentUid, chatPartnerId)
        
        let messageDocId = messagesRef.documentID
        
        let message = Message(
            messageId: messageDocId,
            fromId: chatPartnerId,
            toId: currentUid,
            messageText: messageText,
            timestamp: timestamp,
            unread: true,
            isUnsend: false
        )
        
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }

        messagesRef.setData(messageData)
        recentRefs.forEach { $0.setData(messageData) }
    }
    
    func observeMessages(completion: @escaping([Message]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        let query = ChatService.getMessagesCollectionRef(for: currentUid, chatPartnerId)
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
    
    func updateUnreadMessage(idMessage: String){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        let messagesRef = ChatService.getMessagesCollectionRef(for: currentUid, chatPartnerId).document(idMessage)
        let recentRefs = ChatService.getRecentRef(for: currentUid, chatPartnerId)
        
        let updateUnread: [String: Any] = [
            "unread": false
        ]
        
        messagesRef.setData(updateUnread, merge: true)
        recentRefs.forEach { $0.setData(updateUnread, merge: true) }
     }
    
    func unsendMessage(with msgId: String, isLast: Bool) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
                
        let messagesRef = ChatService.getMessagesCollectionRef(for: currentUid, chatPartnerId).document(msgId)
        let recentRefs = ChatService.getRecentRef(for: currentUid, chatPartnerId)
        
        let updateUnread: [String: Any] = [
            "isUnsend": true
        ]
        
        messagesRef.setData(updateUnread, merge: true)
//        messagesRef.delete()
               
        if isLast {
            let query = ChatService.getMessagesCollectionRef(for: currentUid, chatPartnerId)
                .order(by: "timestamp", descending: false)
                .whereField("isUnsend", isEqualTo: "false")
                .limit(to: 1)
            Task {
                let msg = try await query.getDocuments()
                guard let message = try msg.documents.first?.data(as: Message.self) else { return }
                let messageData = try Firestore.Encoder().encode(message)
                recentRefs.forEach { $0.setData(messageData) }
            }
        }
    }
    
    private static func getMessagesCollectionRef(for args: String...) -> CollectionReference {
        let combinedChatId = getCombinedChatId(with: args)
        
        return FirestoreConstans.MessagesCollection
            .document(combinedChatId)
            .collection("messages")
    }
    
    private static func getCombinedChatId(with args: [String]) -> String {
        let combinedString = args.sorted().joined()

        let data = combinedString.data(using: .utf8)!

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }

        let hexString = hash.map { String(format: "%02x", $0) }.joined()

        return hexString
    }
    
    private static func getRecentRef(for args: String...) -> [DocumentReference] {
        var result: [DocumentReference] = []
        for (index, fid) in args.enumerated() {
            for sid in args[(index + 1)...] {
                let firsrtRef = FirestoreConstans.MessagesCollection
                    .document(fid)
                    .collection("recent-messages")
                    .document(sid)
                
                let secondRef = FirestoreConstans.MessagesCollection
                    .document(sid)
                    .collection("recent-messages")
                    .document(fid)
                
                result.append(contentsOf: [firsrtRef, secondRef])
            }
        }
        
        return result
    }
}
