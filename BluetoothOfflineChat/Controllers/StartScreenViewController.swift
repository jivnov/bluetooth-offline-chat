//
//  StartScreenViewController.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 04/05/2023.
//

import UIKit

class StartScreenViewController: UIViewController {

    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    
    override func viewDidLoad() {
        navigationController?.navigationBar.isHidden = true
        super.viewDidLoad()
        
        loginButtonOutlet.layer.backgroundColor = Constants.colors.darkColor.cgColor
        loginButtonOutlet.layer.cornerRadius = loginButtonOutlet.frame.height / 2
        loginButtonOutlet.titleLabel?.text = "Login"
        loginButtonOutlet.titleLabel?.tintColor = .white
        loginButtonOutlet.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        loginButtonOutlet.alpha = 0
        
        UIView.animate(withDuration: 1) {
                self.loginButtonOutlet.alpha = 1.0
            }
        
        loginButtonOutlet.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.loginButtonOutlet.transform = .identity
        }, completion: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
       
    }
    
}
