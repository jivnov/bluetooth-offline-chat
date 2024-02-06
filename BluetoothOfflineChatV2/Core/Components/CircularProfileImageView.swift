//
//  CircularProfileImageView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 20/01/2024.
//

import SwiftUI

enum ProfileImageSize {
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    case xLarge
    
    var dimension: CGFloat {
        switch self {
        case .xxSmall:
            28
        case .xSmall:
            32
        case .small:
            40
        case .medium:
            56
        case .large:
            64
        case .xLarge:
            80
        }
    }
}

struct CircularProfileImageView: View {
    @Environment(\.colorScheme) var colorScheme
    let user: User?
    let size: ProfileImageSize
    
    var body: some View {
        if let imageUrl = user?.profileImageUrl {
            AsyncImage(url:  URL(string: imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: size.dimension, height: size.dimension)
                        .foregroundStyle(ColorConstans.getAppPrimalyGrayColor(darkMode: colorScheme == .dark, baseColor: .systemGray4))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                default:
                    getEmptyProfileImage()
                }
            }
        } else {
            getEmptyProfileImage()
        }
    }
    
    private func getEmptyProfileImage() -> some View {
        return Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: size.dimension, height: size.dimension)
            .foregroundStyle(ColorConstans.getAppPrimalyGrayColor(darkMode: colorScheme == .dark, baseColor: .systemGray4))
    }
}

#Preview {
    CircularProfileImageView(user: User.MOCK_USER, size: .medium)
}
