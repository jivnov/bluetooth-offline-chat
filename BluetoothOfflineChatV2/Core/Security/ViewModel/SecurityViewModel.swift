//
//  SecurityViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 17/01/2025.
//

import Foundation
import Combine

class SecurityViewModel: ObservableObject {
    @Published var isPasswordEnabled: Bool
    @Published var isBiometricEnabled: Bool
    @Published var passcode = ""
    @Published var shouldPresentPasscodeInputView = false
    @Published var shouldEmptyPasscode = false
    @Published var options: SecurityOptionsViewModel = .noPasscode
    
    private var repasscode = ""
    private var nextOption: SecurityOptionsViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        isPasswordEnabled = SecurityService.retrievePasscode() != nil
        isBiometricEnabled = SecurityService.isBiometricEnabled()
        setupPasscodeListener()
    }
    
    func startPasscodeSet() {
        shouldPresentPasscodeInputView.toggle()
        passcode = ""
        shouldEmptyPasscode.toggle()
    }
    
    func startPasscodeChange() {
        shouldPresentPasscodeInputView.toggle()
        options = .changePasscode
        passcode = ""
        shouldEmptyPasscode.toggle()
    }
    
    func disablePasscode() {
        shouldPresentPasscodeInputView.toggle()
        options = .disablePasscode
        passcode = ""
        shouldEmptyPasscode.toggle()
    }
    
    func changeBiometricStatus() -> String? {
        if let err = SecurityService.canUseBiometricAuthentication() {
            return err
        }
        
        shouldPresentPasscodeInputView.toggle()
        options = .setBiometrics
        passcode = ""
        shouldEmptyPasscode.toggle()
        return nil
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
        case .noPasscode:
            noPasscode(handle: fullPasscode)
        case .mismatchPasscode:
            noPasscode(handle: fullPasscode)
        case .reEnterPasscode:
            reEnterPasscode(handle: fullPasscode)
        case .changePasscode:
            changePasscode(handle: fullPasscode)
        case .wrongPasscode:
            guard let nxtopt = nextOption else { return }
            options = nxtopt
            nextOption = nil
            handleFullPasscode(fullPasscode)
        case .disablePasscode:
            disablePasscode(handle: fullPasscode)
        case .setBiometrics:
            setBiometrics(handle: fullPasscode)
        }
    }
    
    private func noPasscode(handle fullPasscode: String) {
        guard repasscode.isEmpty else { return }
        repasscode = fullPasscode
        options = .reEnterPasscode
        shouldEmptyPasscode.toggle()
    }
    
    private func reEnterPasscode(handle fullPasscode: String) {
        if fullPasscode == repasscode {
            SecurityService.savePasscode(fullPasscode)
            isPasswordEnabled = true
            repasscode = ""
            shouldEmptyPasscode.toggle()
            shouldPresentPasscodeInputView.toggle()
        }
        else {
            repasscode = ""
            options = .mismatchPasscode
            shouldEmptyPasscode.toggle()
        }
    }
    
    private func changePasscode(handle fullPasscode: String) {
        let currentPasscode = SecurityService.retrievePasscode()
        shouldEmptyPasscode.toggle()
        if fullPasscode == currentPasscode {
            options = .noPasscode
        }
        else {
            options = .wrongPasscode
            nextOption = .changePasscode
        }
    }
    
    private func disablePasscode(handle fullPasscode: String) {
        let currentPasscode = SecurityService.retrievePasscode()
        shouldEmptyPasscode.toggle()
        if fullPasscode == currentPasscode {
            shouldPresentPasscodeInputView.toggle()
            isPasswordEnabled = false
            options = .noPasscode
            SecurityService.deletePasscode()
            
            if isBiometricEnabled {
                isBiometricEnabled = false
                SecurityService.setBiometricState(isOn: isBiometricEnabled)
            }
        }
        else {
            options = .wrongPasscode
            options = .disablePasscode
        }
    }
    
    private func setBiometrics(handle fullPasscode: String) {
        let currentPasscode = SecurityService.retrievePasscode()
        shouldEmptyPasscode.toggle()
        if fullPasscode == currentPasscode {
            shouldPresentPasscodeInputView.toggle()
            isBiometricEnabled.toggle()
            SecurityService.setBiometricState(isOn: isBiometricEnabled)
            options = .noPasscode
        }
        else {
            options = .wrongPasscode
            nextOption = .setBiometrics
        }
    }
}

enum SecurityOptionsViewModel: Int, CaseIterable {
    case noPasscode
    case mismatchPasscode
    case reEnterPasscode
    case changePasscode
    case wrongPasscode
    case disablePasscode
    case setBiometrics
        
    var title: String {
        switch self {
        case .noPasscode:
            return String(localized: "Set Passcode")
        case .mismatchPasscode:
            return String(localized: "Passcodes do not match! Try again.")
        case .reEnterPasscode:
            return String(localized: "Re-enter passcode")
        case .changePasscode:
            return String(localized: "Change Passcode")
        case .wrongPasscode:
            return String(localized: "Wrong passcode! Try again.")
        case .disablePasscode:
            return String(localized: "Provide passcode to disable it.")
        case .setBiometrics:
            return String(localized: "Provide passcode to change biometric settings.")
        }
    }
}
