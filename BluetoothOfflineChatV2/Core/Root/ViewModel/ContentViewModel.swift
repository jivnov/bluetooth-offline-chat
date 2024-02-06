//
//  ContentViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 21/01/2024.
//

import Firebase
import Combine

class ContentViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupUserSession()
    }
    
    private func setupUserSession() {
        AuthService.shared.$userSession.sink { [weak self] userSessionFromAuthService in
            guard let strongSelf = self else {return}
            strongSelf.userSession = userSessionFromAuthService
            if userSessionFromAuthService == nil {UserDefaults.standard.set(ColorSchemeMode.system.rawValue, forKey: "appearance_scheme")}
        }.store(in: &cancellables)
    }
}
