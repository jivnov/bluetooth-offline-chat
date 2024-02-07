//
//  ChatConnectivity.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 28/01/2024.
//

import Foundation
import MultipeerConnectivity

class ChatConnectivity: NSObject, ObservableObject {
    static let shared = ChatConnectivity()
    
    private let service = "bluetooth-chat"
    private let advertiserAssistant: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private let session: MCSession
    
    private var foundUsers: Dictionary<String, MCPeerID> = Dictionary()
    private var foundUsersByPeerId: Dictionary<MCPeerID, String> = Dictionary()
    private var connectedUsers: Dictionary<String, MCPeerID> = Dictionary()
    
    private var reconnectionAttempts: Dictionary<MCPeerID, Int> = Dictionary()
    
    @Published var users = [User]()

    private override init() {
        let userName = UserService.shared.currentUser?.fullName
        let userId = UserService.shared.currentUser?.uid ?? UUID().uuidString
        let peerId : MCPeerID = MCPeerID(displayName: userName ?? UIDevice.current.name)
        session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        advertiserAssistant = MCNearbyServiceAdvertiser(
            peer: peerId,
            discoveryInfo: ["userId" : userId],
            serviceType: service
        )
        serviceBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: service)
        
        super.init()
        
        session.delegate = self
        advertiserAssistant.delegate = self
        serviceBrowser.delegate = self
    }
    
    func send(message msg: [String : String], to peerIdString: String) {
        guard let peerId = self.connectedUsers[peerIdString],
              session.connectedPeers.contains(peerId)
        else { return }
            
            do {
                let data = try JSONEncoder().encode(msg)
                try session.send(data, toPeers: [peerId], with: .reliable)
            } catch {
                print(error.localizedDescription)
            }
    }
    
    
    func startConnectivity() {
        advertiserAssistant.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    func stopConnectivity() {
        advertiserAssistant.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func sendInventation(to partnerId: String?) {
        guard let partnerId = partnerId,
              let peerId = self.foundUsers[partnerId],
           !self.session.connectedPeers.contains(peerId),
            let uid = UserService.shared.currentUser?.uid,
            let uidData = uid.data(using: .utf8)
        else { return }
        
        serviceBrowser.invitePeer(peerId, to: self.session, withContext: uidData, timeout: 10)
        self.connectedUsers[partnerId] = peerId
    }
}

extension ChatConnectivity: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        guard let ctx = context, let uid = String(data: ctx, encoding: .utf8) else { return }
        self.connectedUsers[uid] = peerID
        if self.users.filter( {$0.uid == uid} ).count == 0 {
            self.users.append(User(uid: uid, fullName: peerID.displayName, email: ""))
        }
        invitationHandler(true, session)
    }
}

extension ChatConnectivity: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        do {
            let data = try JSONDecoder().decode([String : String].self, from: data)
            ChatService.getOfflineMessage(from: foundUsersByPeerId[peerID], messageData: data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
//            addToConnectedPeers(peerID)
            print("Connected to: \(peerID.displayName)")
        case .notConnected:
//            removeFromConnectedPeers(peerID)
            self.reconnect(to: peerID)
            print("Not connected")
        case .connecting:
            print("Connecting to: \(peerID.displayName)") // TODO: Dialog to allow connection
        @unknown default:
            print("Unknown state: \(state)")
        }
    }
    
    private func reconnect(to peer: MCPeerID) {
        if let attempts = self.reconnectionAttempts[peer] {
            if attempts >= 2 {
                self.reconnectionAttempts[peer] = 0
                return
            }
            self.reconnectionAttempts[peer]! += 1
        }
        else {
            self.reconnectionAttempts[peer] = 1
        }
        
        self.sendInventation(to: self.foundUsersByPeerId[peer])
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
    
    public func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}

extension ChatConnectivity: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        //TODO: Tell the user something went wrong and try again
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let info = info, let uid = info["userId"] else { return }
        DispatchQueue.main.async {
            self.users.append(User(uid: uid, fullName: peerID.displayName, email: ""))
            self.foundUsers[uid] = peerID
            self.foundUsersByPeerId[peerID] = uid
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        let uid = self.foundUsersByPeerId[peerID] ?? ""
        DispatchQueue.main.async {
            self.users.removeAll(where: {
                $0.uid == uid
            })
            
            self.foundUsers.removeValue(forKey: uid)
            self.foundUsersByPeerId.removeValue(forKey: peerID)
        }
        
    }
}
