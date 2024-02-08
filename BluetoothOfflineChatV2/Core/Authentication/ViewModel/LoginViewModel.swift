//
//  LoginViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 21/01/2024.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var shouldShakeEmail = false
    @Published var shouldShakePassword = false
    @Published var email = ""
    @Published var password = ""
    
    func tryToLogin() {
        if email.isEmpty {
            shouldShakeEmail.toggle()
        } else if password.isEmpty {
            shouldShakePassword.toggle()
        } else {
            Task { try await self.login() }
        }
    }
    
    func login() async throws {
        try await AuthService.shared.login(withEmail: email, password: password)
    }
}
