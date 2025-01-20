//
//  PasscodeLoginViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 20/01/2025.
//

import Foundation
import Combine

class PasscodeLoginViewModel: SecurityViewModel {
    override init() {
        super.init()
        options = .enterPasscode
        shouldPresentPasscodeInputView = SecurityService.retrievePasscode() != nil
    }
    
    func getBiometricType() -> String? {
        return SecurityService.getBiometricType()
    }
    
    @MainActor
    func tryBiometricAuthentication() {
        Task {
            do {
                let result = try await SecurityService.authenticateWithBiometrics()
                self.shouldPresentPasscodeInputView = !result
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    override func handleFullPasscode(_ fullPasscode: String) {
        switch options {
        case .enterPasscode, .mismatchPasscode:
            handlePasscode(fullPasscode)
        case .wrongPasscode:
            handlePasscode(fullPasscode)
        default:
            return
        }
    }

    private func handlePasscode(_ fullPasscode: String) {
        if fullPasscode == SecurityService.retrievePasscode() {
            shouldPresentPasscodeInputView = false
        } else {
            options = .wrongPasscode
        }
        
        shouldEmptyPasscode.toggle()
    }
}
