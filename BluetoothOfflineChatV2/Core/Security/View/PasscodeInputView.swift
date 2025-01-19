//
//  PasscodeInputView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 17/01/2025.
//

import SwiftUI

struct PasscodeInputView: View {
    @State private var passcodeInput: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @Binding var passcode: String
    @Binding var shouldEmptyPasscode: Bool
    var title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()

            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .strokeBorder(
                            passcode.count > index ?
                            ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark) :
                                ColorConstans.getAppPrimalyGrayColor(darkMode: colorScheme == .dark), lineWidth: 2
                        )
                        .background(
                            passcode.count > index ?
                            Circle().fill(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark)) :
                                Circle().fill(Color.clear)
                        )
                        .frame(width: 20, height: 20)
                }
            }
            
            TextField("", text: $passcode)
            .keyboardType(.numberPad)
            .focused($isTextFieldFocused)
            .frame(width: 0, height: 0)
        }
        .onChange(of: shouldEmptyPasscode, { _, _ in
            passcode = ""
        })
        .onAppear { isTextFieldFocused = true }
    }
}
