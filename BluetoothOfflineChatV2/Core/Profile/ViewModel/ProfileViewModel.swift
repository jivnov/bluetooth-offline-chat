//
//  ProfileViewModel.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 13/01/2024.
//

import SwiftUI
import PhotosUI

class ProfileViewModel: ObservableObject {
    
    let service: ProfileService
    
    init(user: User) {
        self.service = ProfileService(user: user)
    }
    
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { try await loadImage() } }
    }
    
    @Published var profileImage: Image?
    
    @MainActor
    func loadImage() async throws {
        guard let item = selectedItem else {return}
        guard let imageData = try await item.loadTransferable(type: Data.self) else {return}
        guard let uiImage = UIImage(data: imageData) else {return}
        self.profileImage = Image(uiImage: uiImage)
        Task { try await service.updateUserProfileImage(with: uiImage) }
    }
    
    func changeNetworkState(isOn: Bool) {
        if isOn {
            AppNetworkMode.setAppMode(.offline)
        }
        else {
            AppNetworkMode.setAppMode(.online)
        }
    }
}
