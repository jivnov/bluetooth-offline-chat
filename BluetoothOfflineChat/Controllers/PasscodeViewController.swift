//
//  PasscodeController.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 16/05/2023.
//

import UIKit

class PasscodeViewController: UIViewController, ObservableObject {
    
    @Published var pressedNumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let outerStack = UIStackView()
        outerStack.axis = .vertical
        outerStack.distribution = .fillEqually
        outerStack.spacing = 16
        
        let possibleNumbers: [[Int]] = [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
            [0],
        ]
        
        possibleNumbers.forEach { rowNums in
            let hStack = UIStackView()
            hStack.distribution = .fillEqually
            hStack.spacing = outerStack.spacing
            rowNums.forEach { n in
                let passcodeBtn = PasscodeButton()
                passcodeBtn.setTitle("\(n)", for: [])
                if rowNums.count != 1 {
                    passcodeBtn.heightAnchor.constraint(equalTo: passcodeBtn.widthAnchor).isActive = true
                }
                passcodeBtn.addTarget(self, action: #selector(numberTapped(_:)), for: .touchUpInside)
                hStack.addArrangedSubview(passcodeBtn)
            }
            outerStack.addArrangedSubview(hStack)
        }
        
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outerStack)
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: g.topAnchor, constant: 40.0),
            outerStack.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20.0),
            outerStack.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20.0),
        ])
        
    }
    
    @objc func numberTapped(_ sender: UIButton) {
        guard let number = sender.currentTitle else {
            return
        }
        pressedNumber = number
    }
    
}

class PasscodeButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
    }
    
    private func setupButton() {
        setTitleColor(UIColor.black, for: .normal)
        setTitleColor(UIColor.lightGray, for: .highlighted)
        layer.masksToBounds = true
        layer.borderColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0, alpha:1).cgColor
        layer.borderWidth = 2.0
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
    }
    
}
