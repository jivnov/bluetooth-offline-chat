//
//  SettingsViewController.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 16/05/2023.
//

import UIKit
import AuthenticationServices

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var changeNameBtn: UIButton!
    @IBOutlet weak var enablePassText: UILabel!
    @IBOutlet weak var enablePassSwitch: UISwitch!
    @IBOutlet weak var changePassBtn: UIButton!
    @IBOutlet weak var enableBAText: UILabel!
    @IBOutlet weak var enableBASwitch: UISwitch!
    
    @IBOutlet var sideMenuBtn: UIBarButtonItem!
    
    private var actionSaveName: UIAlertAction!
    private var actionSavePass: UIAlertAction!
    private var disableAlertAction: UIAlertAction!
    
    private var oldPassValid: Bool = true
    private var newPassValue: String = ""
    private var repeatNewPassValue: String = ""
    
    private let chatConnectionManager = (UIApplication.shared.delegate as! AppDelegate).chatConnectionManager
    private let keychainHelper = KeychainHelper()
    private let biometricHelper = BiometricHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navBar = navigationController?.navigationBar {
            navBar.isHidden = false
            navBar.scrollEdgeAppearance = UINavigationBarAppearance()
            navBar.addShadow(color: .black, opacity: 0.70, radius: 7)
        }
        
        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
        
        setAppearanceFor(button: changeNameBtn)
        setAppearanceFor(button: changePassBtn)
        
        enablePassSwitch.addTarget(self, action: #selector(onPassSwitchValueChanged), for: .valueChanged)
        enableBASwitch.addTarget(self, action: #selector(onBASwitchValueChanged), for: .valueChanged)
        enableBASwitch.setOn(biometricHelper.isBiometricEnabled(), animated: true)
        
        hidePassFieldsIfNeeded()
    }
    
    private func setAppearanceFor(button: UIButton) {
        button.layer.backgroundColor = Constants.colors.darkColor.cgColor
        button.layer.cornerRadius = button.frame.height / 2
        button.titleLabel?.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    }
    
    @objc private func onPassSwitchValueChanged(_ switch: UISwitch) {
        
        if UserDefaults.standard.bool(forKey: "passwordEnabled") {
            disableAuthenticationAlert()
        }
        else {
            showChangePassAlert(oldPassExist: false)
        }
    }
    
    private func disableAuthenticationAlert() {
        let disableAlert = UIAlertController(title: "Disable authentication?", message: "", preferredStyle: UIAlertController.Style.alert )
        
        disableAlert.addTextField { (passField) in
            passField.placeholder = "Enter password"
            passField.isSecureTextEntry = true
            passField.delegate = self
            passField.addTarget(self, action: #selector(self.disablePassFieldChanged(_:)), for: .editingChanged)
        }
        
        disableAlertAction = UIAlertAction(title: "Disable", style: .destructive)  { (alertAction) in
            UserDefaults.standard.set(false, forKey: "passwordEnabled")
            self.oldPassValid = true
            self.keychainHelper.removePassword()
            self.biometricHelper.setBiometricEnabled(enabled: false)
            self.hidePassFieldsIfNeeded()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)  { (alertAction) in
            self.enablePassSwitch.setOn(true, animated: true)
        }
        
        disableAlertAction.isEnabled = false
        disableAlert.addAction(disableAlertAction)
        disableAlert.addAction(cancel)
        
        self.present(disableAlert, animated:true, completion: nil)
    }
    
    @objc private func disablePassFieldChanged(_ field: UITextField) {
        disableAlertAction.isEnabled = field.text! == keychainHelper.getPassword()
    }
    
    private func hidePassFieldsIfNeeded() {
        let passwordEnabled = UserDefaults.standard.bool(forKey: "passwordEnabled")
        let biometricAvailable = biometricHelper.isBiometricAvailable()
        changePassBtn.isHidden = !passwordEnabled
        enableBAText.isHidden = !passwordEnabled || !biometricAvailable
        enableBASwitch.isHidden = !passwordEnabled || !biometricAvailable
        enablePassSwitch.setOn(passwordEnabled, animated: false)
    }
    
    @objc private func onBASwitchValueChanged(_ switch: UISwitch) {
        
        biometricHelper.setBiometricEnabled(enabled: enableBASwitch.isOn)
    }
    
    @IBAction func changeNameBtnPressed(_ sender: UIButton) {
        showChangeNameAlert()
    }
    
    private func showChangeNameAlert() {
        let alert = UIAlertController(title: "Change name", message: "Note: you will have to create a new chats and session after changing name", preferredStyle: UIAlertController.Style.alert )
        actionSaveName = UIAlertAction(title: "Save", style: .destructive) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                self.chatConnectionManager.setNewPeerName(textField.text!)
                UserDefaults.standard.set(textField.text!, forKey: "userName")
            }
        }
        
        alert.addTextField { (nameField) in
            nameField.placeholder = "Enter new name"
            nameField.addTarget(self, action: #selector(self.nameFieldDidChange(_:)), for: .editingChanged)
        }
        actionSaveName.isEnabled = false
        alert.addAction(actionSaveName)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        
        self.present(alert, animated:true, completion: nil)
        
    }
    
    @objc private func nameFieldDidChange(_ field: UITextField) {
        actionSaveName.isEnabled = field.text?.count ?? 0 > 0
    }
    
    @IBAction func changePassBtnPressed(_ sender: UIButton) {
        showChangePassAlert(oldPassExist: true)
    }
    
    private func showChangePassAlert(oldPassExist: Bool) {
        let alertName = oldPassExist ? "Change passcode" : "Set new passcode"
        let alert = UIAlertController(title: alertName, message: "Enter new passcode and repeat it in second field. Passcode should consist from 4 to 6 digits", preferredStyle: UIAlertController.Style.alert )
        actionSavePass = UIAlertAction(title: "Save", style: oldPassExist ? .destructive : .default) { (alertAction) in
            if oldPassExist {
                self.keychainHelper.updatePassword(self.newPassValue)
            }
            else {
                UserDefaults.standard.set(true, forKey: "passwordEnabled")
                self.hidePassFieldsIfNeeded()
                self.keychainHelper.addNewPassword(self.newPassValue)
            }
            self.newPassValue = ""
            self.repeatNewPassValue = ""
            self.oldPassValid = false
            
        }
        
        if oldPassExist {
            oldPassValid = false
            alert.addTextField { (oldPassField) in
                oldPassField.placeholder = "Old password"
                oldPassField.isSecureTextEntry = true
                oldPassField.delegate = self
                oldPassField.addTarget(self, action: #selector(self.oldPassFieldChange(_:)), for: .editingChanged)
            }
        }
        
        alert.addTextField { (firstPassField) in
            firstPassField.placeholder = "New password"
            firstPassField.isSecureTextEntry = true
            firstPassField.delegate = self
            firstPassField.addTarget(self, action: #selector(self.newPassFieldChange(_:)), for: .editingChanged)
        }
        
        alert.addTextField { (secondPassField) in
            secondPassField.placeholder = "Repeat password"
            secondPassField.isSecureTextEntry = true
            secondPassField.delegate = self
            secondPassField.addTarget(self, action: #selector(self.repeatNewPassFieldChange(_:)), for: .editingChanged)
        }
        
        actionSavePass.isEnabled = false
        alert.addAction(actionSavePass)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            self.newPassValue = ""
            self.repeatNewPassValue = ""
            if !UserDefaults.standard.bool(forKey: "passwordEnabled") {
                self.enablePassSwitch.setOn(false, animated: true)
            }
            else {
                self.oldPassValid = false
            }
        }
        alert.addAction(cancel)
        
        self.present(alert, animated:true, completion: nil)
        
    }
    
    @objc private func oldPassFieldChange(_ field: UITextField) {
        oldPassValid = field.text! == self.keychainHelper.getPassword()
        checkIfCanSavePass()
    }
    
    @objc private func newPassFieldChange(_ field: UITextField) {
        newPassValue = field.text!
        checkIfCanSavePass()
    }
    
    @objc private func repeatNewPassFieldChange(_ field: UITextField) {
        repeatNewPassValue = field.text!
        checkIfCanSavePass()
    }
    
    private func checkIfCanSavePass() {
        let samePasswords = newPassValue == repeatNewPassValue
        let correctLen = 4 <= newPassValue.count && 6 >= newPassValue.count
        actionSavePass.isEnabled = oldPassValid && samePasswords && correctLen
    }
    
    //MARK - UITextField Delegates
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
