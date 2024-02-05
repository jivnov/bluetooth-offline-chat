//
//  Route.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 26/01/2024.
//

import Foundation

enum Route: Hashable {
    case profile(User)
    case chatView(User)
}
