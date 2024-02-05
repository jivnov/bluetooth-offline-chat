//
//  NewMessageViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 22/01/2024.
//

import Foundation
import Firebase
import Combine

@MainActor
class NewMessageViewModel: ObservableObject {
    @Published var users = [User]()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        switch AppNetworkMode.getAppMode() {
        case .online:
            Task { try await fetchUsers() }
        case .offline:
            fetchOfflineUsers()
        }
    }
    
    func fetchUsers() async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let users = try await UserService.fetchAllUsers()
        self.users = users.filter({ $0.id != currentUserId})
    }
    
    func fetchOfflineUsers()  {
        ChatConnectivity.shared.$users.sink { [weak self] browsedUsers in
            guard let strongSelf = self else {return}
            strongSelf.users = browsedUsers
        }.store(in: &cancellables)
    }
}
