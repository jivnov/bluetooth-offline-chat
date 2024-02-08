//
//  ForgotPasswordViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 07/02/2024.
//

import Foundation

class ForgotPasswordViewModel: ObservableObject {
    @Published var shouldShake = false
    @Published var email = ""
    
    func tryToResetPassword() {
        if email.isEmpty {
            shouldShake.toggle()
        }
        else {
            Task { try await AuthService.shared.resetPassword(email: email) }
        }
    }
}
