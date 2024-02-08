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
    
    init() {
        setupSubscribers()
        InboxService.shared.observeRecentMessages()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser.sink { [weak self] user in
            guard let strongSelf = self else {return}
            strongSelf.currentUser = user
        }.store(in: &cancellables)
        
        InboxService.shared.$documentChanges.sink { [weak self] changes in
            guard let strongSelf = self else {return}
            Task { try await strongSelf.loadInitialMessages(fromChanges: changes) }
        }.store(in: &cancellables)
    
    }
    
    @MainActor
    private func loadInitialMessages(fromChanges changes: [DocumentChange]) async throws {
        let messages = changes.compactMap({ try? $0.document.data(as: Message.self) })
        
        for i in 0..<messages.count {
            var message = messages[i]
            
            if let existingIndex = self.recentMessages.firstIndex(where: { $0.fromId == message.chatPartnerId || $0.toId == message.chatPartnerId }) {
                message.user = self.recentMessages[existingIndex].user
                recentMessages.remove(at: existingIndex)
                self.recentMessages.insert(message, at: 0)
                
                continue
            }
            
            message.user = try await UserService.fetchUser(withUid:  message.chatPartnerId)
            self.recentMessages.append(message)
        }
    }

    func nabigationTitle(by offlineEnabled: Bool) -> String {
        return offlineEnabled ? String(localized: "Offline chats") : String(localized: "Chats")
    }
}
