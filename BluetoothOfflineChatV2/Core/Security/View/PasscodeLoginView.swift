//
//  PasscodeLoginView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 20/01/2025.
//

import SwiftUI

struct PasscodeLoginView: View {
    @StateObject var viewModel = PasscodeLoginViewModel()

    var body: some View {
        VStack {
            if viewModel.shouldPresentPasscodeInputView {
                PasscodeInputView(
                    passcode: $viewModel.passcode,
                    shouldEmptyPasscode: $viewModel.shouldEmptyPasscode,
                    title: viewModel.options.title
                )
                
                if viewModel.isBiometricEnabled,
                    let type = viewModel.getBiometricType() {
                    Button {
                        viewModel.tryBiometricAuthentication()
                    } label: {
                        Image(systemName: type)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(ColorConstans.appDarkBlueColor)
                            .cornerRadius(16)
                    }
                }
            } else {
                InboxView()
            }
        }
    }
}
