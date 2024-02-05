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
            
            VStack {
                HStack {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
//                        .foregroundStyle(Color(red: 10/255, green: 61/255, blue: 145/255))
                        .padding(.horizontal, 10)
                    
                    TextField("Enter your name", text: $viewModel.fullName)
                        .autocapitalization(.words)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.trailing, 24)
                }
                .frame(width: fieldsWidth )
                
                HStack {
                    Image(systemName: "envelope.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 10)
                    
                    TextField("Enter your email", text: $viewModel.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.trailing, 24)
                }
                .frame(width: fieldsWidth )
                
                HStack {
                    Image(systemName: "lock.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 10)
                    
                    SecureField("Enter your password", text: $viewModel.password)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.trailing, 24)
                }
                .frame(width: fieldsWidth )
            }
            
            Button {
                Task { try await viewModel.createUser() }
            } label: {
                Text("Sign Up")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 180, height: 44)
                    .background(Color(red: 10/255, green: 61/255, blue: 145/255))
                    .cornerRadius(16)
            }
            .padding(.vertical)
            
            Spacer()
            
            Divider()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(Color(red: 103/255, green: 179/255, blue: 249/255))
                
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    RegistrationView()
}
