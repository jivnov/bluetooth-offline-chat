//
//  NewMessageView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 07/01/2024.
//

import SwiftUI

struct NewMessageView: View {
    @State private var searchText = ""
    @StateObject private var viewModel = NewMessageViewModel()
    @Binding var selectedUser: User?
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                TextField("To: ", text: $searchText)
                    .frame(height: 44)
                    .padding(.leading)
                    .background(Color(.systemGray6))
                
                Text("Contacts")
                    .foregroundStyle(.gray)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                ForEach(viewModel.users) { user in
                    VStack {
                        HStack {
                            CircularProfileImageView(user: user, size: .small)
                            
                            Text(user.fullName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.leading)
                        
                        Divider()
                            .padding(.leading, 40)
                    }
                    .onTapGesture {
                        switch AppNetworkMode.getAppMode() {
                        case .online:
                            selectedUser = user
                        case .offline:
                            ChatConnectivity.shared.sendInventation(to: user.uid)
                            selectedUser = user
                        }
                        dismiss()
                    }
                }
                
            }
            .navigationTitle("New message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark))
                }
        }
        }
    }
}

#Preview {
    NewMessageView(selectedUser: .constant(User.MOCK_USER))
}
