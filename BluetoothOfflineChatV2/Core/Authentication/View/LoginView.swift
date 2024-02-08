//
//  LoginView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 07/01/2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @Environment(\.colorScheme) var colorScheme
    private var isIpad : Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var fieldsWidth : Double {
        isIpad ? (UIScreen.main.bounds.width / 2) : UIScreen.main.bounds.width
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isIpad {
                    Spacer()
                }
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding()
                
                loginTextFields
                
                forgotPasswordButton
                
                loginButton
                
                orDivideLine
                
                googleLoginButton
                
                Spacer()
                
                registrationNavigationLink
            }
        }
    }
    
    private var loginTextFields: some View {
        VStack {
            HStack {
                AuthenticationImageView(imageName: "envelope.circle", darkModeEnabled: colorScheme == .dark)
                
                TextField("Enter your email", text: $viewModel.email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
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
                    .cornerRadius(16)
                    .padding(.trailing, 24)
                    .modifier(ShakeEffect(shakes: viewModel.shouldShakePassword ? 2 : 0))
                    .animation(Animation.default.repeatCount(2).speed(1), value:  viewModel.shouldShakePassword)
            }
            .frame(width: fieldsWidth )
        }
        .onSubmit {
            viewModel.tryToLogin()
        }
    }
    
    private var forgotPasswordButton: some View {
        NavigationLink {
            ForgotPasswordView()
                .navigationBarBackButtonHidden()
        } label: {
            Text("Forgot password?")
                .font(.footnote)
                .fontWeight(.semibold)
                .padding(.top)
                .padding(.trailing, 28)
        }
        .foregroundStyle(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark))
        .frame(maxWidth: fieldsWidth, alignment: .trailing)
    }
    
    private var loginButton: some View {
        Button {
            viewModel.tryToLogin()
        } label: {
            Text("Login")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 180, height: 44)
                .background(ColorConstans.appDarkBlueColor)
                .cornerRadius(16)
        }
        .padding(.vertical)
    }
    
    private var orDivideLine: some View {
        HStack {
            Rectangle()
                .frame(width: (UIScreen.main.bounds.width / 2) - 40, height: 0.5)
            
            Text("OR")
                .font(.footnote)
                .fontWeight(.semibold)
            
            Rectangle()
                .frame(width: (UIScreen.main.bounds.width / 2) - 40, height: 0.5)
        }
        .foregroundStyle(.gray)
    }
    
    private var googleLoginButton: some View {
        Button {
            
        } label: {
            Text("Continue with Google")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 180, height: 44)
                .background(Color(.systemRed))
                .cornerRadius(16)
        }
        .padding(.top, 8)
    }
    
    private var registrationNavigationLink: some View {
        NavigationLink {
            RegistrationView()
                .navigationBarBackButtonHidden()
        } label: {
            HStack(spacing: 3) {
                Text("Don't have an account?")
                
                Text("Sign Up")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
        .foregroundStyle(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark))
    }
}

#Preview {
    LoginView()
}
