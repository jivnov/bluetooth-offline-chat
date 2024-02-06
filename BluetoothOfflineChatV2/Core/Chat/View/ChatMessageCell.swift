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
    
    private var isFromCurrentUser: Bool {
        return message.isFromCurrentUser
    }
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
                
                Text(message.messageText)
                    .font(.subheadline)
                    .padding(12)
//                    .background(ColorConstans.getAppPrimalyBlueColor(darkMode: colorScheme == .dark))
                    .background(ColorConstans.appDarkBlueColor) // TODO: dark is better
                    .foregroundStyle(.white)
                    .clipShape(ChatBubble(isFromCurrentUser: isFromCurrentUser))
                    .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .trailing)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
//                    CircularProfileImageView(user: message.user, size: .xxSmall)
                    
                    Text(message.messageText)
                        .font(.subheadline)
                        .padding(12)
                        .background(ColorConstans.getAppPrimalyGrayColor(darkMode: colorScheme == .dark))
//                        .foregroundStyle(.black) // TODO: Probably without it
                        .clipShape(ChatBubble(isFromCurrentUser: isFromCurrentUser))
                        .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

//#Preview {
//    ChatMessageCell(isFromCurrentUser: false)
//}
