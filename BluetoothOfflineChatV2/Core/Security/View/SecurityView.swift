//
//  SecurityView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 17/01/2025.
//

import SwiftUI

struct SecurityView: View {
    @State private var showAlert: SecurityAlertType? = nil
    @StateObject var viewModel = SecurityViewModel()

    @State private var biometricsError: String = ""

    var body: some View {
        VStack {
            if viewModel.shouldPresentPasscodeInputView {
                PasscodeInputView(
                    passcode: $viewModel.passcode,
                    shouldEmptyPasscode: $viewModel.shouldEmptyPasscode,
                    title: viewModel.options.title
                )
            } else {
                mainContent
            }
        }
        .navigationTitle("Passcode & Security")
        .alert(item: $showAlert) { alertType in
            switch alertType {
            case .disablePasscode:
                return Alert(
                    title: Text("Disable Passcode?"),
                    message: Text("Are you sure you want to disable the passcode?"),
                    primaryButton: .destructive(Text("Disable")) {
                        viewModel.disablePasscode()
                    },
                    secondaryButton: .cancel()
                )
            case .biometricError:
                return Alert(
                    title: Text("Biometric Error"),
                    message: Text(biometricsError),
                    dismissButton: .default(Text("OK")) {
                        biometricsError = ""
                    }
                )
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if !viewModel.isPasswordEnabled {
            VStack {
                Text("Set up a passcode to secure your data.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)

                actionButton(String(localized: "Set Passcode"), action: viewModel.startPasscodeSet)
            }
        } else {
            VStack {
                actionButton(viewModel.isBiometricEnabled ? String(localized: "Disable Biometrics") : String(localized: "Enable Biometrics")) {
                    if let error = viewModel.changeBiometricStatus() {
                        biometricsError = error
                        showAlert = .biometricError
                    }
                }

                actionButton(String(localized: "Change Passcode"), action: viewModel.startPasscodeChange)

                actionButton(String(localized: "Disable Passcode")) {
                    showAlert = .disablePasscode
                }
            }
        }
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 180, height: 44)
                .background(ColorConstans.appDarkBlueColor)
                .cornerRadius(16)
        }
        .padding(.vertical)
    }
}

enum SecurityAlertType: Identifiable {
    case disablePasscode
    case biometricError

    var id: Int {
        switch self {
        case .disablePasscode: return 0
        case .biometricError: return 1
        }
    }
}
