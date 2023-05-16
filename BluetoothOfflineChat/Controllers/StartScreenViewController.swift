//
//  StartScreenViewController.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 04/05/2023.
//

import UIKit

class StartScreenViewController: UIViewController {
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    private var actionSave: UIAlertAction!
    
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
        
        //        let userName = UserDefaults.standard.string(forKey: "userName")
        if UserDefaults.standard.string(forKey: "userName") == nil {
            alertWithTF()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
    }
    
    func alertWithTF() {
        let alert = UIAlertController(title: "Your name", message: "Please input your name, which will be visible for others", preferredStyle: UIAlertController.Style.alert )
        actionSave = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                UserDefaults.standard.set(textField.text!, forKey: "userName")
            }
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your name"
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
        actionSave.isEnabled = false
        alert.addAction(actionSave)
        
        self.present(alert, animated:true, completion: nil)
        
    }
    
    @objc private func textFieldDidChange(_ field: UITextField) {
        actionSave.isEnabled = field.text?.count ?? 0 > 0
    }
    
}
