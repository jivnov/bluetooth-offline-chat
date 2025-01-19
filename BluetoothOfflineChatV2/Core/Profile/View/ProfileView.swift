//
//  ProfileView.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 13/01/2024.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    let user: User
    
    private var isIpad : Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var fieldsWidth : Double {
        isIpad ? (UIScreen.main.bounds.width * 0.75) : UIScreen.main.bounds.width
    }
        
    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
    }
    
    var body: some View {
        VStack {
            VStack {
                PhotosPicker(selection: $viewModel.selectedItem) {
                    if let profileImage = viewModel.profileImage {
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        CircularUserImageView(user: user, size: .xLarge)
                    }
                }
                
                Text(user.fullName)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            List {
                Section {
                    ForEach(SettingsOptionsViewModel.allCases) { option in
                        if option.hasSpecialView {
                            option.specialView
                        }
                        else {
                            if option.isButton {
                                NavigationLink(destination: option.specialView) {
                                                HStack {
                                                    Image(systemName: option.imageName)
                                                        .resizable()
                                                        .frame(width: 24, height: 24)
                                                        .foregroundStyle(option.imageBackgroundColor)
                                                    
                                                    Text(option.title)
                                                        .font(.subheadline)
                                                }
                                            }
                            } else {
                                HStack {
                                    Image(systemName: option.imageName)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundStyle(option.imageBackgroundColor)
                                    
                                    Text(option.title)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button("Log Out") {
                        AuthService.shared.signOut()
                    }
                    
                    Button("Delete account") {
                        
                    }
                }
                .foregroundStyle(.red)
            }
            .frame(width: fieldsWidth )
        }
    }
}

#Preview {
    ProfileView(user: User.MOCK_USER)
}
