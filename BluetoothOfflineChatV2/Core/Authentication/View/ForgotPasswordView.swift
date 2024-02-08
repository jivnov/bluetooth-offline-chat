//
//  ForgotPasswordView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 07/02/2024.
//

import SwiftUI

struct ForgotPasswordView: View {
    @StateObject var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private var isIpad : Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var fieldsWidth : Double {
        isIpad ? (UIScreen.main.bounds.width / 2) : UIScreen.main.bounds.width
    }
    
    var body: some View {
        VStack{
            if isIpad {
                Spacer()
            }
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding()
            
            emailTextField
            
            resetButton
            
            Text("Enter your email address and we will send you a link to reset your password.")
                .foregroundStyle(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark))
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            backToLoginButton
        }
    }
    
    private var emailTextField: some View{
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
                .modifier(ShakeEffect(shakes: viewModel.shouldShake ? 2 : 0))
                .animation(Animation.default.repeatCount(2).speed(1), value:  viewModel.shouldShake)
        }
        .frame(width: fieldsWidth )
        .onSubmit {
            viewModel.tryToResetPassword()
        }
    }
    
    private var resetButton: some View{
        Button{
            viewModel.tryToResetPassword()
        }label: {
            Text("Send")
                .font(.subheadline)
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
    ForgotPasswordView()
}
