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
    @Published var isBiometricEnabled = false
    @Published var passcode = ""
    @Published var shouldPresentPasscodeInputView = false
    @Published var shouldEmptyPasscode = false
    @Published var options: SecurityOptionsViewModel = .noPasscode
    
    private var repasscode = ""
    private var changingPasscode = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        isPasswordEnabled = SecurityService.retrievePasscode() != nil
        setupPasscodeListener()
    }
    
    func startPasscodeSet() {
        shouldPresentPasscodeInputView.toggle()
        passcode = ""
        shouldEmptyPasscode.toggle()
    }
    
    func startPasscodeChange() {
        changingPasscode = true
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
            changingPasscode ? changePasscode(handle: fullPasscode) : disablePasscode(handle: fullPasscode)
        case .disablePasscode:
            disablePasscode(handle: fullPasscode)
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
            changingPasscode = false
        }
        else {
            options = .wrongPasscode
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
        }
        else {
            options = .wrongPasscode
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
        }
    }
}
