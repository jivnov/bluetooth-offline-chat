//
//  NetworkStateView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 03/02/2024.
//

import SwiftUI

struct NetworkStateView: View {
    @State private var enabled = AppNetworkMode.offlineModeEnabled()
    let option = SettingsOptionsViewModel.offlineMode
    
    var body: some View {
        HStack {
            Image(systemName: option.imageName)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(option.imageBackgroundColor)
            
            Toggle(option.title, isOn: $enabled)
                .onChange(of: enabled) { value in
                    AppNetworkMode.changeNetworkState(isOn: value)
            }
            
        }
    }
}

#Preview {
    NetworkStateView()
}
