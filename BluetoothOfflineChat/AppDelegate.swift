//
//  AppDelegate.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 04/05/2023.
//

import UIKit
import CoreData
import Foundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BluetoothChatModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let err = error as NSError? {
                fatalError("Unresolved error \(err), \(err.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let err = error as NSError
                fatalError("Unresolved error \(err), \(err.userInfo)")
            }
        }
    }


}

