//
//  InboxViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 22/01/2024.
//

import Foundation
import Combine
import Firebase

class InboxViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var recentMessages = [Message]()
    
    private var cancellables = Set<AnyCancellable>()
    private let service = InboxService() //TODO: create share instance
    
    init() {
        setupSubscribers()
        service.observeRecentMessages()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser.sink { [weak self] user in
            guard let strongSelf = self else {return}
            strongSelf.currentUser = user
        }.store(in: &cancellables)
        
        service.$documentChanges.sink { [weak self] changes in
            guard let strongSelf = self else {return}
            strongSelf.loadInitialMessages(fromChanges: changes)
        }.store(in: &cancellables)
    
    }
    
    private func loadInitialMessages(fromChanges changes: [DocumentChange]) {
        var messages = changes.compactMap({ try? $0.document.data(as: Message.self) })
        
        for i in 0..<messages.count {
            let message = messages[i]
            
            for (idx, msg) in recentMessages.enumerated() {
                if msg.fromId == message.chatPartnerId || msg.toId == message.chatPartnerId {
                    recentMessages.remove(at: idx)
                }
            }
            
            UserService.fetchUser(withUid: message.chatPartnerId) { user in
                messages[i].user = user
                self.recentMessages.insert(messages[i], at: 0)
            }
        }
    }
    
    func nabigationTitle(by offlineEnabled: Bool) -> String {
        return offlineEnabled ? "Offline Chats" : "Chats"
    }
}
