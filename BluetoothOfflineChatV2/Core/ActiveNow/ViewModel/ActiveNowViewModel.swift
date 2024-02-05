//
//  ActiveNowViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 26/01/2024.
//

import Foundation
import Firebase

class ActiveNowViewModel: ObservableObject {
    @Published var users = [User]()
    
    init() {
        Task { try await fetchUsers() }
    }
    
    @MainActor
    private func fetchUsers() async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let users = try await UserService.fetchAllUsers(limit: 5)
        self.users = users.filter({ $0.id != currentUserId})
    }
}
