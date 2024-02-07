//
//  CircularUserImageView.swift
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

struct CircularUserImageView: View {
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
                    if user != nil {
                        getCharProfileImage
                    }
                    else {
                        getEmptyProfileImage
                    }

                }
            }
        } else {
            if user != nil {
                getCharProfileImage
            }
            else {
                getEmptyProfileImage
            }

        }
    }
    
    private var getCharProfileImage: some View {
        let color = RandomUserPhotoHelper.randomColor()
        let textColor: Color = RandomUserPhotoHelper.isLight(color: color) ? .black : .white
        return Image(systemName: "circle")
            .resizable()
            .frame(width: size.dimension, height: size.dimension)
            .foregroundStyle(color)
            .overlay(
                Text(user!.initialsFromName)
                    .foregroundStyle(textColor)
                    .font(Font.custom("Sans Serif", size: size.dimension/3)),
                alignment: .center
            )
            .background(color)
            .clipShape(Circle())
    }
    
    private var getEmptyProfileImage: some View {
        let color = RandomUserPhotoHelper.randomColor()
        return Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: size.dimension, height: size.dimension)
            .foregroundStyle(color)
    }
}

#Preview {
    CircularUserImageView(user: User.MOCK_USER, size: .medium)
}
