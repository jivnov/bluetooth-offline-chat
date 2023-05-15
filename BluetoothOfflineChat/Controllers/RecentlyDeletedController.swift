//
//  RecentlyDeletedController.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 09/05/2023.
//

import UIKit
import CoreData

class RecentlyDeletedController: UIViewController {

    @IBOutlet weak var deletedChatTableView: UITableView!
    @IBOutlet var sideMenuBtn: UIBarButtonItem!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var chatPreview = [ChatPreview]()

    override func viewDidLoad() {
        super.viewDidLoad()

        showSpinner()

        deletedChatTableView.rowHeight = 68
        deletedChatTableView.separatorStyle = .none
        deletedChatTableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)

        if let navBar = navigationController?.navigationBar {
            navBar.isHidden = false
                navBar.scrollEdgeAppearance = UINavigationBarAppearance()
                navBar.addShadow(color: .black, opacity: 0.38, radius: 7)
        }

        deletedChatTableView.dataSource = self
        deletedChatTableView.delegate = self
        loadDeletedChats()
        
        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
    }

    override func viewDidAppear(_ animated: Bool) {
        loadDeletedChats()
    }

    override func viewWillDisappear(_ animated: Bool) {

    }

    //MARK: - Manipulations with data

    private func loadDeletedChats() {
        let request : NSFetchRequest<ChatPreview> = ChatPreview.fetchRequest()
        let sort = NSSortDescriptor(key: "chatDate", ascending: false)
        let predicateNotDeleted = NSPredicate(format: "chatDeleted == 1")
        request.sortDescriptors = [sort]
        request.predicate = predicateNotDeleted

        do {
            chatPreview = try context.fetch(request)
        }
        catch {
            print("loadDeletedChats error: \(error)")
        }
        
        showNoChatsView(chats: chatPreview.count)
        deletedChatTableView.reloadData()
    }

    private func saveDeletedChats() {
        do {
            try context.save()
        }
        catch {
            print("saveDeletedChats error \(error)")
        }

        loadDeletedChats()
    }
}

extension RecentlyDeletedController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatPreview.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! ChatPreviewTableViewCell
        cell.lastChatMessagePreviewLabel.text = chatPreview[indexPath.row].chatName
        cell.lastChatMessageTimeLabel.text = chatPreview[indexPath.row].chatTime
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deletedChat = self.chatPreview[indexPath.row]
        let refreshAlert = UIAlertController(title: deletedChat.chatName, message: "What to do with this chat?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Restore", style: .default, handler: { (action: UIAlertAction!) in
            deletedChat.chatDeleted = "0"
            self.saveDeletedChats()
          }))
        
        refreshAlert.addAction(UIAlertAction(title: "Delete forever", style: .destructive, handler: { (action: UIAlertAction!) in
            self.context.delete(deletedChat)
            self.saveDeletedChats()
          }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in

        }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
}
