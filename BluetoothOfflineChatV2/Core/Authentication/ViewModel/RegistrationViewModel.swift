//
//  RegistrationViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 21/01/2024.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var shouldShakeEmail = false
    @Published var shouldShakePassword = false
    @Published var shouldShakeName = false
    
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    
    func tryToCreateUser() {
        if fullName.isEmpty {
            shouldShakeName.toggle()
        } else if email.isEmpty {
            shouldShakeEmail.toggle()
        } else if password.isEmpty {
            shouldShakePassword.toggle()
        } else {
            Task { try await self.createUser() }
        }
    }
    
    private func createUser() async throws {
        try await AuthService.shared.createUser(withEmail: email, password: password, fullName: fullName)
    }
}
