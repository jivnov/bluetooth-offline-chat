//
//  RegistrationView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 07/01/2024.
//

import SwiftUI

struct RegistrationView: View {
    @StateObject var viewModel = RegistrationViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private var isIpad : Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var fieldsWidth : Double {
        isIpad ? (UIScreen.main.bounds.width / 2) : UIScreen.main.bounds.width
    }
    
    var body: some View {
        VStack {
            if isIpad {
                Spacer()
            }
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding()
            
            registrationTextFields
            
            signUpButton
            
            Spacer()
            
            Divider()
            
            backToLoginButton
        }
    }
    
    private var registrationTextFields: some View {
        VStack {
            HStack {
                AuthenticationImageView(imageName: "person.circle", darkModeEnabled: colorScheme == .dark)
                
                TextField("Enter your name", text: $viewModel.fullName)
                    .autocapitalization(.words)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.trailing, 24)
                    .modifier(ShakeEffect(shakes: viewModel.shouldShakeName ? 2 : 0))
                    .animation(Animation.default.repeatCount(2).speed(1), value:  viewModel.shouldShakeName)
            }
            .frame(width: fieldsWidth )
            
            HStack {
                AuthenticationImageView(imageName: "envelope.circle", darkModeEnabled: colorScheme == .dark)
                
                TextField("Enter your email", text: $viewModel.email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.trailing, 24)
                    .modifier(ShakeEffect(shakes: viewModel.shouldShakeEmail ? 2 : 0))
                    .animation(Animation.default.repeatCount(2).speed(1), value:  viewModel.shouldShakeEmail)
            }
            .frame(width: fieldsWidth )
            
            HStack {
                AuthenticationImageView(imageName: "lock.circle", darkModeEnabled: colorScheme == .dark)
                
                SecureField("Enter your password", text: $viewModel.password)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.trailing, 24)
                    .modifier(ShakeEffect(shakes: viewModel.shouldShakePassword ? 2 : 0))
                    .animation(Animation.default.repeatCount(2).speed(1), value:  viewModel.shouldShakePassword)
            }
            .frame(width: fieldsWidth )
        }
        .onSubmit {
            viewModel.tryToCreateUser()
        }
    }
    
    private var signUpButton: some View {
        Button {
            viewModel.tryToCreateUser()
        } label: {
            Text("Sign Up")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 180, height: 44)
                .background(ColorConstans.appDarkBlueColor)
                .cornerRadius(16)
        }
        .padding(.vertical)
    }
    
    private var backToLoginButton: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 3) {
                Text("Already have an account?")
                
                Text("Sign In")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundStyle(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark))
            
        }
        .padding(.vertical)
    }
}

#Preview {
    RegistrationView()
}
