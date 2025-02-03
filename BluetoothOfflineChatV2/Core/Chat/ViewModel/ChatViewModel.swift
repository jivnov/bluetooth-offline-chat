//
//  ChatViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 26/01/2024.
//

import Foundation

class ChatViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var messages = [Message]()
    
    let service: ChatService
    
    init(user: User) {
        self.service = ChatService(chatPartner: user)
        observeMessages()
    }
    
    func observeMessages() {
        self.service.observeMessages() { messages in
            if self.messages.isEmpty {
                self.messages.append(contentsOf: messages)
            } else {
                for newMessage in messages {
                    if let idx = self.messages.firstIndex(where: { $0.messageId == newMessage.messageId }) {
                        self.messages[idx] = newMessage
                    } else {
                        self.messages.append(newMessage)
                    }
                }
            }
            
            self.messages = self.messages.filter( { $0.isUnsend == false } )
        }
    }
    
    func sendMessage() {
        self.service.sendMessage(messageText)
    }
    
    func unsendMessage(with msgId: String) {
         self.service.unsendMessage(with: msgId, isLast: messages.last?.messageId == msgId)
    }
}
