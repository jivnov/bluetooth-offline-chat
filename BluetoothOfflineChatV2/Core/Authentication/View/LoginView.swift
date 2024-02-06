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
                
                VStack {
                    HStack {
                        Image(systemName: "envelope.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(.horizontal, 10)
                            .foregroundStyle(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark))
                        
                        TextField("Enter your email", text: $viewModel.email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .padding(.trailing, 24)
                    }
                    .frame(width: fieldsWidth )
                    
                    HStack {
                        Image(systemName: "lock.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(.horizontal, 10)
                            .foregroundStyle(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark))
                        
                        SecureField("Enter your password", text: $viewModel.password)
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .padding(.trailing, 24)
                    }
                    .frame(width: fieldsWidth )
                }
                
                Button {
                    print("Forgot password")
                } label: {
                    Text("Forgot password?")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .padding(.top)
                        .padding(.trailing, 28)
                }
                .foregroundStyle(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark))
                .frame(maxWidth: fieldsWidth, alignment: .trailing)
                
                Button {
                    Task { try await viewModel.login() }
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
                
                
                Spacer()
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden()
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                    .font(.footnote)
                }
                .foregroundStyle(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark))
            }
        }
    }
}

#Preview {
    LoginView()
}
