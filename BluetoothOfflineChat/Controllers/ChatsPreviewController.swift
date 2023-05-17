//
//  ChatsPreviewController.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 04/05/2023.
//

import UIKit
import SwiftUI
import CoreData
import MultipeerConnectivity
import Combine

class ChatsPreviewController: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet var sideMenuBtn: UIBarButtonItem!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var chatPreview = [ChatPreview]()
    
    private let chatConnectionManager = (UIApplication.shared.delegate as! AppDelegate).chatConnectionManager
    
    private var cancellableBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSpinner()
        
        chatTableView.rowHeight = 68
        chatTableView.separatorStyle = .none
        chatTableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        if let navBar = navigationController?.navigationBar {
            navBar.isHidden = false
            navBar.scrollEdgeAppearance = UINavigationBarAppearance()
            navBar.addShadow(color: .black, opacity: 0.70, radius: 7)
        }
        
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
        
        chatConnectionManager.$newMessage.sink { _ in
            DispatchQueue.main.async {
                self.chatTableView.reloadData()
            }
            
        }.store(in: &cancellableBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadChats()
        self.revealViewController()?.gestureRecognizerShouldWork(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.revealViewController()?.gestureRecognizerShouldWork(true)
    }
    
    //MARK: - Manipulations with data
    
    private func loadChats() {
        let request : NSFetchRequest<ChatPreview> = ChatPreview.fetchRequest()
        let sort = NSSortDescriptor(key: "chatDate", ascending: false)
        let predicateNotDeleted = NSPredicate(format: "chatDeleted == 0")
        request.sortDescriptors = [sort]
        request.predicate = predicateNotDeleted
        
        do {
            chatPreview = try context.fetch(request)
        }
        catch {
            print("loadChats error: \(error)")
        }
        
        loadConnectedPeers()
        
        showNoChatsView(chats: chatPreview.count)
        chatTableView.reloadData()
    }
    
    private func loadConnectedPeers() {
        let connectedPeers = chatConnectionManager.getConnectedPeers()
        
        if connectedPeers.isEmpty {
            return
        }
        
        var chatKnownPeers: [Data] = []
        let request : NSFetchRequest<ChatPreview> = ChatPreview.fetchRequest()
        
        do {
            let allChats = try context.fetch(request)
            for i in allChats {
                chatKnownPeers.append(i.chatPeerId!)
            }
        }
        catch {
            print("loadConnectedPeers error: \(error)")
        }
        
        for peer in connectedPeers {
            if !chatKnownPeers.contains(peer) {
                createNewChat(peer)
            }
        }
        
        saveChats()
    }
    
    func createNewChat(_ peerIdData: Data) {
        let newChat = ChatPreview(context: context)
        let uuid = UUID().uuidString
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let minutesStr = minutes > 10 ? "\(minutes)" : "0\(minutes)"
        
        newChat.chatDate = date
        newChat.chatId = uuid
        newChat.chatPeerId = peerIdData
        newChat.chatTime = "\(hour):\(minutesStr)"
        newChat.chatDeleted = "0"
        chatPreview.append(newChat)
    }
    
    private func saveChats() {
        do {
            try context.save()
        }
        catch {
            print("saveChats error \(error)")
        }
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        chatConnectionManager.startConnection()
    }
    
}

extension ChatsPreviewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatPreview.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! ChatPreviewTableViewCell
        do {
            let peerId = try NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: chatPreview[indexPath.row].chatPeerId!)!
            cell.lastChatMessagePreviewLabel.text = peerId.displayName
        }
        catch {
            print("Failed to set chat name: \(error)")
        }
        cell.lastChatMessageTimeLabel.text = chatPreview[indexPath.row].chatTime
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ChatsViewController
        
        if let indexPath = chatTableView.indexPathForSelectedRow {
            destinationVC.setSelectedChat(chatPreview[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { (action, view, completionHandler) in
            let chatToRemove = self.chatPreview[indexPath.row]
            chatToRemove.chatDeleted = "1"
            self.saveChats()
            self.loadChats()
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(named: "iconDelete")!
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
}
