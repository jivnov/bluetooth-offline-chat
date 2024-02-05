//
//  AppearanceChangeView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 05/02/2024.
//

import SwiftUI

struct AppearanceChangeView: View {
    @State var colorScheme = ToggleState.on.rawValue
    let option = SettingsOptionsViewModel.darkMode
    
    enum ToggleState: String, CaseIterable {
        case off = "Off"
        case on = "On"
        case system = "System"
    }
    
    var body: some View {
        HStack {
            Image(systemName: option.imageName)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(option.imageBackgroundColor)
            
            Text(option.title)
                .font(.subheadline)
            
            Spacer()
            Menu(colorScheme) {
                Button(ToggleState.on.rawValue) { colorScheme = ToggleState.on.rawValue }
                Button(ToggleState.off.rawValue) { colorScheme = ToggleState.off.rawValue }
                Button(ToggleState.system.rawValue) { colorScheme = ToggleState.system.rawValue }
            }
//                                .buttonStyle(.borderedProminent)
            
        }
    }
}

#Preview {
    AppearanceChangeView()
}
