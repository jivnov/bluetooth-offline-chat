//
//  ProfileService.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 26/01/2024.
//

import Foundation
import Firebase
import FirebaseStorage

struct ProfileService {
    let user: User
    
    @MainActor
    func updateUserProfileImage(with image: UIImage) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard  let uploadData = image.jpegData(compressionQuality: 0.1) else { return }
        let storageRef = Storage.storage().reference().child("profile_images").child("\(currentUid).jpg")
        let _ = try await storageRef.putDataAsync(uploadData)
        let url = try await storageRef.downloadURL()
                
        let user = User(fullName: user.fullName, email: user.email, profileImageUrl: url.absoluteString)
        UserService.shared.currentUser?.profileImageUrl = url.absoluteString
        guard let encodedUser = try? Firestore.Encoder().encode(user) else {return}
        try await FirestoreConstans.UserCollection.document(currentUid).setData(encodedUser)
    }
}
