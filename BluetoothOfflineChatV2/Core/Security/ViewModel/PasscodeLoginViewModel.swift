//
//  PasscodeLoginViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 20/01/2025.
//

import Foundation
import Combine

class PasscodeLoginViewModel: ObservableObject {
    @Published var isBiometricEnabled: Bool
    @Published var passcode = ""
    @Published var shouldPresentPasscodeInputView: Bool
    @Published var shouldEmptyPasscode = false
    @Published var options: SecurityOptionsViewModel = .enterPasscode

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.shouldPresentPasscodeInputView = SecurityService.retrievePasscode() != nil
        self.isBiometricEnabled = SecurityService.isBiometricEnabled()
        setupPasscodeListener()
    }
    
    func getBiometricType() -> String? {
        return SecurityService.getBiometricType()
    }
    
    @MainActor
    func tryBiometricAuthentication() {
        Task {
            do {
                let result = try await SecurityService.authenticateWithBiometrics()
                self.shouldPresentPasscodeInputView = false
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    private func setupPasscodeListener() {
        $passcode
            .removeDuplicates()
            .filter { $0.count == 6 }
            .sink { [weak self] fullPasscode in
                self?.handleFullPasscode(fullPasscode)
            }
            .store(in: &cancellables)
    }

    private func handleFullPasscode(_ fullPasscode: String) {
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
