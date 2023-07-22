//
//  ChatConnectivity.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 10/05/2023.
//

import Foundation
import MultipeerConnectivity
import CoreData

class ChatConnectivity: NSObject, ObservableObject {
    private static let service = "bluetooth-chat"
    
    @Published var newMessage: Messages!
    private var myPeerId : MCPeerID!
    private var advertiserAssistant: MCNearbyServiceAdvertiser?
    private var session: MCSession?
    private var isHosting = false
    
    private var connectedPeersSet : Set<Data> = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getPeerId() -> MCPeerID {
        var peerId : MCPeerID = MCPeerID(displayName: UIDevice.current.name)
        if UserDefaults.standard.data(forKey: "myPeerId") == nil {
            peerId = MCPeerID(displayName: UserDefaults.standard.string(forKey: "userName")!)
            do {
                let peerIDData = try NSKeyedArchiver.archivedData(withRootObject: peerId, requiringSecureCoding: false)
                UserDefaults.standard.set(peerIDData, forKey: "myPeerId")
            }
            catch {
                print("get peerIDData error \(error)")
            }
        }
        else {
            do {
                peerId = try NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: UserDefaults.standard.data(forKey: "myPeerId")!)!
            }
            catch {
                print("Failed to get Peer Id: \(error)")
            }
        }
        return peerId
    }
    
    func sendMessage(text message: String, chat: ChatPreview) -> Bool {
        guard
            let session = session,
            let data = message.data(using: .utf8),
            !session.connectedPeers.isEmpty
        else { return false}
        
        if !connectedPeersSet.contains(chat.chatPeerId!) {
            return false
        }
        
        do {
            let peerId = try NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: chat.chatPeerId!)!
            try session.send(data, toPeers: [peerId], with: .reliable)
        } catch {
            print(error.localizedDescription)
            return false
        }
        
        return true
    }
    
    func startConnection() {
        
        myPeerId = getPeerId()
        
        if session == nil {
            
            session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
            session?.delegate = self
            
            advertiserAssistant = MCNearbyServiceAdvertiser(
                peer: myPeerId,
                discoveryInfo: nil,
                serviceType: ChatConnectivity.service
            )
            advertiserAssistant?.delegate = self
            advertiserAssistant?.startAdvertisingPeer()
        }
        
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first,
            let session = session
        else { return }
        
        let mcBrowserViewController = MCBrowserViewController(serviceType: ChatConnectivity.service, session: session)
        mcBrowserViewController.delegate = self
        mcBrowserViewController.modalPresentationStyle = .fullScreen
        window.rootViewController?.present(mcBrowserViewController, animated: true)
    }
    
    func getConnectedPeers() -> Set<Data> {
        return connectedPeersSet
    }
    
    func setNewPeerName(_ name: String) {
        session?.disconnect()
        
        let peerId : MCPeerID = MCPeerID(displayName: name)
        do {
            let peerIDData = try NSKeyedArchiver.archivedData(withRootObject: peerId, requiringSecureCoding: false)
            UserDefaults.standard.set(peerIDData, forKey: "myPeerId")
        }
        catch {
            print("setNewPeerName error \(error)")
        }
    }
}

extension ChatConnectivity: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension ChatConnectivity: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = String(data: data, encoding: .utf8) else { return }
        
        do {
            let peerIDData = try NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: false)
            newMessage = ChatMessageHelper().handleNewMessage(context: context, isSender: false, text: message, selectedChat: nil, peerData: peerIDData)
        }
        catch {
            print("get peerIDData error \(error)")
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            addToConnectedPeers(peerID)
            print("Connected")
        case .notConnected:
            removeFromConnectedPeers(peerID)
            print("Not connected")
        case .connecting:
            print("Connecting to: \(peerID.displayName)") // TODO: Dialog to allow connection
        @unknown default:
            print("Unknown state: \(state)")
        }
    }
    
    private func addToConnectedPeers(_ peerID: MCPeerID) {
        do {
            let peerIDData = try NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: false)
            
            if !connectedPeersSet.contains(peerIDData) {
                connectedPeersSet.insert(peerIDData)
            }
        }
        catch {
            print("get peerIDData error \(error)")
        }
    }
    
    private func removeFromConnectedPeers(_ peerID: MCPeerID) {
        do {
            let peerIDData = try NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: false)
            
            if connectedPeersSet.contains(peerIDData) {
                connectedPeersSet.remove(peerIDData)
            }
        }
        catch {
            print("get peerIDData error \(error)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Receiving chat history")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
}

extension ChatConnectivity: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        //        session?.disconnect()
        browserViewController.dismiss(animated: true)
    }
}
