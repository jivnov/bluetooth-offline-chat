//
//  SecurityView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 17/01/2025.
//

import SwiftUI

struct SecurityView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showConfirmDisablePasscodeAlert: Bool = false
    @StateObject var viewModel = SecurityViewModel()

    var body: some View {
        VStack {
            
            if viewModel.shouldPresentPasscodeInputView {
                PasscodeInputView(passcode: $viewModel.passcode,
                                  shouldEmptyPasscode: $viewModel.shouldEmptyPasscode,
                                  title: viewModel.options.title
                )
            } else if !viewModel.isPasswordEnabled {
                VStack {
                    Text("Set up a passcode to secure your data.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                    
                    setPasscodeButton
                }
            } else {
                VStack {
                    biometricButton

                    changePasscodeButton

                    disablePasscodeButton
                }
            }
        }
        .navigationTitle("Passcode & Security")
        .alert("Disable Passcode?", isPresented: $showConfirmDisablePasscodeAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Disable", role: .destructive) {
                viewModel.disablePasscode()
            }
        }
    }
    
    private var setPasscodeButton: some View {
        Button {
            viewModel.startPasscodeSet()
        } label: {
            Text("Set Passcode")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 180, height: 44)
                .background(ColorConstans.appDarkBlueColor)
                .cornerRadius(16)
        }
        .padding(.vertical)
    }
    
    private var biometricButton: some View {
        Button {
            
        } label: {
            Text(viewModel.isBiometricEnabled ? "Disable Biometrics" : "Enable Biometrics")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 180, height: 44)
                .background(ColorConstans.appDarkBlueColor)
                .cornerRadius(16)
        }
        .padding(.vertical)
    }
    
    private var changePasscodeButton: some View {
        Button {
            viewModel.startPasscodeChange()
        } label: {
            Text("Change Passcode")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 180, height: 44)
                .background(ColorConstans.appDarkBlueColor)
                .cornerRadius(16)
        }
        .padding(.vertical)
    }
    
    private var disablePasscodeButton: some View {
        Button {
            showConfirmDisablePasscodeAlert = true
        } label: {
            Text("Disable Passcode")
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
