//
//  StartScreenViewController.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 04/05/2023.
//

import UIKit
import Combine
import LocalAuthentication

class StartScreenViewController: UIViewController {
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var notCorrectView: UILabel!
    @IBOutlet weak var passcodeView: UIView!
    
    private var passcodeController: PasscodeViewController!
    private let keychainHelper = KeychainHelper()
    private let biometricHelper = BiometricHelper()
    
    private var cancellableBag = Set<AnyCancellable>()
    private var actionSave: UIAlertAction!
    
    private var enteredPasscode: String = ""
    private var biometricCompleted: Bool = false
    
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
        
        let userName = UserDefaults.standard.string(forKey: "userName")
        if userName == nil {
            loginButtonOutlet.isHidden = true
            showSetNameAlert()
        }
        
        if !UserDefaults.standard.bool(forKey: "passwordEnabled") {
            passcodeView.isHidden = true
            if userName != nil {
                loginButtonOutlet.isHidden = true
                self.performSegue(withIdentifier: "goToChats", sender: self)
            }
        }
        
        passcodeController.$pressedNumber.sink { value in
            self.notCorrectView.isHidden = true
            if value != nil {
                self.enteredPasscode.append(value!)
            }
            
        }.store(in: &cancellableBag)
        
        tryToUseBiometric()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
    }
    
    private func tryToUseBiometric() {
        if !biometricHelper.isBiometricEnabled() {
            return
        }
        let context = LAContext()
        let reason = "Unlock chat!"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
            success, authenticationError in
            
            DispatchQueue.main.async {
                if success {
                    self.biometricCompleted = true
                    self.performSegue(withIdentifier: "goToChats", sender: self)
                }
            }
            
        }
    }
    
    func showSetNameAlert() {
        let alert = UIAlertController(title: "Your name", message: "Please input your name, which will be visible for others", preferredStyle: UIAlertController.Style.alert )
        actionSave = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                UserDefaults.standard.set(textField.text!, forKey: "userName")
                self.performSegue(withIdentifier: "goToChats", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "passcodeSegue") {
            guard let destinationVC = segue.destination as? PasscodeViewController else { return }
            passcodeController = destinationVC
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "goToChats" && !authCompleted() && UserDefaults.standard.bool(forKey: "passwordEnabled")  {
            self.notCorrectView.isHidden = false
            return false
        }
        return true
    }
    
    private func authCompleted() -> Bool {
        if biometricCompleted {
            return true
        }
        return self.enteredPasscode == self.keychainHelper.getPassword()
    }
    
}
