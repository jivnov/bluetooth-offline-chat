//
//  ChatMessageCell.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 21/01/2024.
//

import SwiftUI

struct ChatMessageCell: View {
    @Environment(\.colorScheme) var colorScheme
    let message: Message
    
    @StateObject var viewModel: ChatViewModel
    @State private var showMsgDeleteAlert = false
    
    private var isFromCurrentUser: Bool {
        return message.isFromCurrentUser
    }
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
                messageFromCurrentUser
            } else {
                messageFromPartner
            }
        }
        .padding(.horizontal, 8)
        .scrollTransition(topLeading: .interactive,
                          bottomTrailing: .interactive) { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0)
                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                .blur(radius: phase.isIdentity ? 0 : 10)
        }
        .alert(isPresented: $showMsgDeleteAlert) {
            deleteMsgAlert
        }
    }
    
    var deleteMsgAlert: Alert {
        Alert(
            title: Text("Confirm delete message"),
            message: Text("This action cannot be undone"),
            primaryButton: .default(
                Text("Cancel"),
                action: {}
            ),
            secondaryButton: .destructive(
                Text("Confirm"),
                action: {
                    if let msgId = message.messageId {
                        viewModel.unsendMessage(with: msgId)
                    }
                }
            )
        )
    }
}

extension ChatMessageCell {
    private var messageFromCurrentUser: some View {
        VStack {
            messageTextView(bgColor: ColorConstans.appDarkBlueColor,
                            frameWidthDiv: 1.5,
                            alignment: .trailing)
            .foregroundStyle(.white)
        }
    }
    
    private var messageFromPartner: some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack {
                messageTextView(bgColor: ColorConstans.getAppPrimalyGrayColor(darkMode: colorScheme == .dark),
                                frameWidthDiv: 1.75,
                                alignment: .leading)
            }
            
            Spacer()
        }
    }
    
    private func messageTextView(bgColor: Color,
                                 frameWidthDiv: CGFloat,
                                 alignment: Alignment,
                                 fgStyle: Color? = nil) -> some View {
        let shape = ChatBubble(isFromCurrentUser: isFromCurrentUser)
        return Text(message.messageText)
            .font(.subheadline)
            .padding(12)
            .background(bgColor)
            .clipShape(shape)
            .contentShape(.contextMenuPreview, shape)
            .frame(maxWidth: UIScreen.main.bounds.width / frameWidthDiv, alignment: alignment)
            .contextMenu {
                contextMenu
            }
            
    }
    
    private var contextMenu: some View {
        VStack {
            Button {
                let pasteboard = UIPasteboard.general
                pasteboard.string = message.messageText
            } label: {
                menuItem(symbol: "document.on.document", text: "Copy")
            }
            
            if isFromCurrentUser {
                Button {
                    showMsgDeleteAlert.toggle()
                } label: {
                    menuItem(symbol: "pip.remove", text: "Delete message")
                }
            }
            
            Text(message.timestampFullString)
                .font(.subheadline)
        }
    }
    
    @ViewBuilder
    private func menuItem(symbol: String, text: String) -> some View {
        HStack {
            Image(systemName: symbol)
                .imageScale(.medium)
            Text(text)
                .font(.subheadline)
        }
    }
}
