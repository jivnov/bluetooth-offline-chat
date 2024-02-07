//
//  AuthenticationImages.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 06/02/2024.
//

import SwiftUI

struct AuthenticationImageView: View {
    var imageName: String
    var darkModeEnabled: Bool
    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .padding(.horizontal, 10)
            .foregroundStyle(ColorConstans.getAppPrimalyBlueColor(darkMode: darkModeEnabled))
    }
}

#Preview {
    AuthenticationImageView(imageName: "questionmark.circle.fill", darkModeEnabled: true)
}
