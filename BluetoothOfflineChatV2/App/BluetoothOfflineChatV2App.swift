//
//  BluetoothOfflineChatV2App.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 07/01/2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct BluetoothOfflineChatV2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("appearance_scheme") var scheme = ColorSchemeMode.system.rawValue
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.getColorScheme(with: scheme))
        }
    }
}
