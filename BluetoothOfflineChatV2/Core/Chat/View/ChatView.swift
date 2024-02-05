//
//  ChatView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 20/01/2024.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    let user: User
    
    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: ChatViewModel(user: user))
        
        if AppNetworkMode.offlineModeEnabled() { ChatConnectivity.shared.sendInventation(to: user.uid) }
    }
    
    var body: some View {
        VStack {
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            ChatMessageCell(message: message)
                                .id(message.id)
                        }
                    }
                }
                .onAppear {
                    proxy.scrollTo(viewModel.messages.last?.id)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    proxy.scrollTo(viewModel.messages.last?.id)
                }
                
            }
            
            Spacer()
            
            ZStack(alignment: .trailing) {
                TextField("Message...", text: $viewModel.messageText, axis: .vertical)
                    .padding(12)
                    .padding(.trailing, 48)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(Capsule())
                    .font(.subheadline)
                
                Button {
                    viewModel.sendMessage()
                    viewModel.messageText = ""
                } label: {
                    Text("Send")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? true : false)
                .opacity(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
            }
            .padding()
        }
        .navigationTitle(user.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CircularProfileImageView(user: user, size: .xSmall)
            }
        }
    }
}

#Preview {
    ChatView(user: User.MOCK_USER)
}
