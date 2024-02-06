//
//  AppearanceChangeView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 05/02/2024.
//

import SwiftUI

struct AppearanceChangeView: View {
    @AppStorage("appearance_scheme") var scheme = ColorSchemeMode.system.rawValue
    let option = SettingsOptionsViewModel.darkMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: option.imageName)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(colorScheme == .dark ? .white : option.imageBackgroundColor)
            
            Text(option.title)
                .font(.subheadline)
            
            Spacer()
            Menu(scheme) {
                Button(ColorSchemeMode.on.rawValue) { scheme = ColorSchemeMode.on.rawValue }
                Button(ColorSchemeMode.off.rawValue) { scheme = ColorSchemeMode.off.rawValue }
                Button(ColorSchemeMode.system.rawValue) { scheme = ColorSchemeMode.system.rawValue }
            }            
        }
    }
}

#Preview {
    AppearanceChangeView()
}
