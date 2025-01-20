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
        self.isPasswordEnabled = SecurityService.retrievePasscode() != nil
        self.isBiometricEnabled = SecurityService.isBiometricEnabled()
        setupPasscodeListener()
    }

    func startPasscodeSet() {
        startPasscodeAction(for: .noPasscode)
    }

    func startPasscodeChange() {
        startPasscodeAction(for: .changePasscode)
    }

    func disablePasscode() {
        startPasscodeAction(for: .disablePasscode)
    }

    func changeBiometricStatus() -> String? {
        if let error = SecurityService.canUseBiometricAuthentication() {
            return error
        }
        startPasscodeAction(for: .setBiometrics)
        return nil
    }

    private func startPasscodeAction(for option: SecurityOptionsViewModel) {
        options = option
        shouldPresentPasscodeInputView = true
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
        case .noPasscode, .mismatchPasscode:
            handleSetPasscode(fullPasscode)
        case .reEnterPasscode:
            handleReEnterPasscode(fullPasscode)
        case .changePasscode:
            handleChangePasscode(fullPasscode)
        case .disablePasscode:
            handleDisablePasscode(fullPasscode)
        case .setBiometrics:
            handleSetBiometrics(fullPasscode)
        case .wrongPasscode:
            handleWrongPasscode(fullPasscode)
        }
    }

    private func handleSetPasscode(_ fullPasscode: String) {
        guard repasscode.isEmpty else { return }
        repasscode = fullPasscode
        options = .reEnterPasscode
        shouldEmptyPasscode.toggle()
    }

    private func handleReEnterPasscode(_ fullPasscode: String) {
        if fullPasscode == repasscode {
            SecurityService.savePasscode(fullPasscode)
            isPasswordEnabled = true
            resetPasscodeState()
        } else {
            options = .mismatchPasscode
            shouldEmptyPasscode.toggle()
            repasscode = ""
        }
    }

    private func handleChangePasscode(_ fullPasscode: String) {
        guard let currentPasscode = SecurityService.retrievePasscode() else { return }
        shouldEmptyPasscode.toggle()

        if fullPasscode == currentPasscode {
            options = .noPasscode
        } else {
            options = .wrongPasscode
            nextOption = .changePasscode
        }
    }

    private func handleDisablePasscode(_ fullPasscode: String) {
        guard let currentPasscode = SecurityService.retrievePasscode() else { return }
        shouldEmptyPasscode.toggle()

        if fullPasscode == currentPasscode {
            SecurityService.deletePasscode()
            isPasswordEnabled = false
            resetBiometricState()
            resetPasscodeState()
        } else {
            options = .wrongPasscode
            nextOption = .disablePasscode
        }
    }

    private func handleSetBiometrics(_ fullPasscode: String) {
        guard let currentPasscode = SecurityService.retrievePasscode() else { return }
        shouldEmptyPasscode.toggle()

        if fullPasscode == currentPasscode {
            isBiometricEnabled.toggle()
            SecurityService.setBiometricState(isOn: isBiometricEnabled)
            resetPasscodeState()
        } else {
            options = .wrongPasscode
            nextOption = .setBiometrics
        }
    }

    private func handleWrongPasscode(_ fullPasscode: String) {
        guard let next = nextOption else { return }
        options = next
        nextOption = nil
        handleFullPasscode(fullPasscode)
    }

    private func resetPasscodeState() {
        repasscode = ""
        shouldPresentPasscodeInputView = false
        shouldEmptyPasscode.toggle()
        options = .noPasscode
    }

    private func resetBiometricState() {
        if isBiometricEnabled {
            isBiometricEnabled = false
            SecurityService.setBiometricState(isOn: false)
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
        case .noPasscode: return String(localized: "Set Passcode")
        case .mismatchPasscode: return String(localized: "Passcodes do not match! Try again.")
        case .reEnterPasscode: return String(localized: "Re-enter passcode")
        case .changePasscode: return String(localized: "Change Passcode")
        case .wrongPasscode: return String(localized: "Wrong passcode! Try again.")
        case .disablePasscode: return String(localized: "Provide passcode to disable it.")
        case .setBiometrics: return String(localized: "Provide passcode to change biometric settings.")
        }
    }
}
