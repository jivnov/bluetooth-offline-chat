//
//  AuthService.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 21/01/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class AuthService {
    @Published var userSession: FirebaseAuth.User?
    
    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
        loadCurrentUserData()
    }
    
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            loadCurrentUserData()
        } catch {
            print("Failed to sigh in user: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            try await self.uploadUserData(email: email, fullname: fullName, id: result.user.uid)
            loadCurrentUserData()
        } catch {
            print("Failed to create user: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            AppNetworkMode.changeNetworkState(isOn: false)
            
            try Auth.auth().signOut()
            self.userSession = nil
            UserService.shared.currentUser = nil
        } catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch{
            print("Failed to reset password: \(error.localizedDescription)")
        }
    }
    
    private func uploadUserData(email: String, fullname: String, id: String) async throws {
        let user = User(fullName: fullname, email: email, profileImageUrl: nil)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else {return}
        try await FirestoreConstans.UserCollection.document(id).setData(encodedUser)
    }
    
    private func loadCurrentUserData() {
        Task {try await UserService.shared.fetchCurrentUser()}
    }
}
