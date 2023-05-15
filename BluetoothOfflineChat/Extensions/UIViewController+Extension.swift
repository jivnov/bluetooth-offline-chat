//
//  UIViewController+Extension.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 04/05/2023.
//

import UIKit
import Foundation

fileprivate var noChatsView : UIView?
fileprivate var spinnerView : UIView?

extension UIViewController {
    
    func showNoChatsView(chats : Int) {
        if chats == 0 {
            Timer.scheduledTimer(withTimeInterval: Constants.timeInterval, repeats: false) { (t) in
                noChatsView = UIView(frame: self.view.bounds)
                noChatsView?.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: noChatsView!.bounds.width, height: noChatsView!.bounds.height))
                let subView = UIView(frame: self.view.bounds)
                subView.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                
                
                label.center = noChatsView!.center
                label.textAlignment = .center
                noChatsView?.addSubview(label)
                noChatsView?.addSubview(subView)
                label.text = "No chats here yet..."
                label.textColor = .darkGray
                label.font = .systemFont(ofSize: 20, weight: .bold)
                UIView.animate(withDuration: 1.0) {
                        subView.alpha = 0.0
                    }
                
                self.view.addSubview(noChatsView!)
            }
        } else {
            hideNoChatsView()
        }
    }
    
    private func hideNoChatsView() {
        noChatsView?.removeFromSuperview()
        noChatsView = nil
    }
    
    func navbarView(height : Int) {
        let navbar = UIView(frame: CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: height + 20))
        navbar.backgroundColor = UIColor.white
        navbar.addShadow(color: .black, opacity: 0.38, radius: 7)
        self.view.addSubview(navbar)
    }
    
    func showSpinner() {
        spinnerView = UIView(frame: self.view.bounds)
        spinnerView?.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
        
        let spinnerImage = UIImageView(image: UIImage(named: "loadingSpinner"))
        
        spinnerView?.addSubview(spinnerImage)
        spinnerImage.center = spinnerView!.center
        spinnerImage.rotate()
        
        self.view.addSubview(spinnerView!)

        Timer.scheduledTimer(withTimeInterval: Constants.timeInterval, repeats: false) { (t) in
            self.hideSpinner()
        }
    }
    
    func hideSpinner() {
        spinnerView?.removeFromSuperview()
        spinnerView = nil
    }
    
    func revealViewController() -> MainViewController? {
        var viewController: UIViewController? = self
        
        if viewController != nil && viewController is MainViewController {
            return viewController! as? MainViewController
        }
        while (!(viewController is MainViewController) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is MainViewController {
            return viewController as? MainViewController
        }
        return nil
    }
}
