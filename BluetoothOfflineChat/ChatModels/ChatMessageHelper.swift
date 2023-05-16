//
//  ChatMessageHelper.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 16/05/2023.
//

import Foundation
import CoreData

class ChatMessageHelper {
    
    func handleNewMessage(context: NSManagedObjectContext, isSender: Bool, text: String, selectedChat: ChatPreview?, peerData: Data?) -> Messages {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let minutesStr = minutes >= 10 ? "\(minutes)" : "0\(minutes)"
        
        let newMessage = Messages(context: context)
        newMessage.messageBody = text
        newMessage.sendTime = "\(hour):\(minutesStr)"
        newMessage.isSender = isSender
        
        if selectedChat != nil {
            newMessage.parentCategory = selectedChat
            selectedChat?.chatTime = newMessage.sendTime
            selectedChat?.chatDate = date
        }
        else {
            let selectedChatPreview = getChatPreview(context: context, peerData: peerData!)
            if selectedChatPreview != nil {
                newMessage.parentCategory = selectedChatPreview!
                selectedChatPreview!.chatTime = newMessage.sendTime
                selectedChatPreview!.chatDate = date
            }
        }
        
        saveNewMessage(context: context)
        
        return newMessage
    }
    
    private func getChatPreview(context: NSManagedObjectContext, peerData: Data) -> ChatPreview? {
        let request : NSFetchRequest<ChatPreview> = ChatPreview.fetchRequest()
        let predicateNotDeleted = NSPredicate(format: "chatPeerId = %@", peerData as CVarArg)
        request.predicate = predicateNotDeleted
        
        do {
            return try context.fetch(request)[0]
        }
        catch {
            print("setMessageBody error: \(error)")
        }
        
        return nil
    }
    
    private func saveNewMessage(context: NSManagedObjectContext){
        do {
            try context.save()
        }
        catch {
            print("newMessage error \(error)")
        }
    }
}
