//
//  ViewController.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 04/05/2023.
//

import UIKit
import CoreData
import Combine
import MultipeerConnectivity

class ChatsViewController: UIViewController {
    
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageViewBottomConstraint: NSLayoutConstraint!
    
    private var messages = [Messages]()
    private var selectedChat: ChatPreview? {
        didSet {
            loadMessages()
        }
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let chatConnectionManager = (UIApplication.shared.delegate as! AppDelegate).chatConnectionManager
    
    private var cancellableBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatCollectionView.dataSource = self
        chatCollectionView.delegate = self
        chatCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        if let navBar = navigationController?.navigationBar {
            navBar.isHidden = false
        }
        
        do {
            let peerId = try NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: selectedChat!.chatPeerId!)!
            self.title = peerId.displayName
        }
        catch {
            print("Failed to set chat name: \(error)")
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        chatConnectionManager.$newMessage.sink { value in
            
            if value != nil {
                if !self.messages.contains(value!) {
                    self.messages.append(value!)
                }
                DispatchQueue.main.async {
                    self.chatCollectionView.reloadData()
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.chatCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                }
            }
            
        }.store(in: &cancellableBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController()?.gestureEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.revealViewController()?.gestureEnabled = true
    }
    
    //MARK: - Textfield above the keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let isKeyboardIsShowing = notification.name == UIResponder.keyboardWillShowNotification
            let window = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .last { $0.isKeyWindow }
            let bottomPadding = window?.safeAreaInsets.bottom
            messageViewBottomConstraint.constant = isKeyboardIsShowing ? (keyboardSize!.height - bottomPadding!) : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut) {
                self.view.layoutIfNeeded()
            } completion: { (completed) in }
            
        }
    }
    
    //MARK: - Manipulations with data
    
    private func loadMessages(with request: NSFetchRequest<Messages> = Messages.fetchRequest(), predicate: NSPredicate? = nil) {
        guard selectedChat != nil else {
            return
        }
        let categoryPredicate = NSPredicate(format: "parentCategory.chatId MATCHES %@", selectedChat!.chatId!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.chatCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        
        do {
            messages = try context.fetch(request)
        }
        catch {
            print("loadMessages error: \(error)")
        }
    }
    
    //MARK: - send button pressed
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let text = messageTextField.text, !text.isEmpty  else {
            return
        }
        
        let completed = chatConnectionManager.sendMessage(text: messageTextField.text!, chat: selectedChat!)
        if !completed {
            showNotCompletedAlert()
            return
        }
        let newMessage = ChatMessageHelper().handleNewMessage(context: context, isSender: true, text: messageTextField.text!, selectedChat: selectedChat, peerData: nil)
        messages.append(newMessage)
        messageTextField.text = ""
        DispatchQueue.main.async {
            self.chatCollectionView.reloadData()
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.chatCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            
        }
    }
    
    private func showNotCompletedAlert() {
        let connectionAlert = UIAlertController(title: "There is no connection with selected chat!", message: "Open settings?", preferredStyle: UIAlertController.Style.alert)
        
        connectionAlert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action: UIAlertAction!) in
            self.chatConnectionManager.startConnection()
        }))
        
        connectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(connectionAlert, animated: true, completion: nil)
    }
    
    func setSelectedChat(_ chat: ChatPreview?) {
        selectedChat = chat
    }
}

extension ChatsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        messageTextField.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = chatCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.messageCollCell, for: indexPath) as! UserMessageCollectionViewCell
        let message = messages[indexPath.row]
        cell.setupCell(message: message)
        
        if message.isSender {
            cell.leftTime.isHidden = false
            cell.rightTime.isHidden = true
            cell.leftTime.textAlignment = .right
            cell.chatMessageFrame.backgroundColor = Constants.colors.darkColor
            cell.messageBody.textAlignment = .right
            cell.messageBody.font = .italicSystemFont(ofSize: 15)
            cell.messageBody.textColor = .white
        } else {
            cell.messageBody.textAlignment = .left
            cell.leftTime.isHidden = true
            cell.rightTime.isHidden = false
            cell.rightTime.textAlignment = .left
            cell.chatMessageFrame.backgroundColor = .white
            cell.messageBody.font = .systemFont(ofSize: 15)
            cell.messageBody.textColor = .black
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages[indexPath.row]
        return CGSize(width: collectionView.bounds.width - 32, height: countHeightForView(text: message.messageBody!, font: .systemFont(ofSize: 15), width: collectionView.bounds.width - 32))
        
    }
    
    private func countHeightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 10, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height + 50
    }
}
