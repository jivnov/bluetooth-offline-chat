//
//  ChatView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 20/01/2024.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    @Environment(\.colorScheme) var colorScheme
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
                .onChange(of: viewModel.messages.count) {
                    proxy.scrollTo(viewModel.messages.last?.id)
                }
                
            }
            
            Spacer()
            
            ZStack(alignment: .trailing) {
                TextField("Message...", text: $viewModel.messageText, axis: .vertical)
                    .padding(12)
                    .padding(.trailing, 48)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                    .font(.subheadline)
                
                Button {
                    viewModel.sendMessage()
                    viewModel.messageText = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark))
                        .imageScale(.large)
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
                CircularUserImageView(user: user, size: .xSmall)
            }
        }
    }
}

#Preview {
    ChatView(user: User.MOCK_USER)
}
