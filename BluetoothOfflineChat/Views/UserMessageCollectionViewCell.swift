//
//  UserMessageCollectionViewCell.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 04/05/2023.
//

import UIKit

class UserMessageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var chatMessageFrame: UIView!
    @IBOutlet weak var leftTime: UILabel!
    @IBOutlet weak var rightTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.translatesAutoresizingMaskIntoConstraints = false
             
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setupCell (message: Messages) {
        self.messageBody.text = message.messageBody
        self.leftTime.text = message.sendTime
        self.rightTime.text = message.sendTime
        self.chatMessageFrame.layer.cornerRadius = 4
        self.chatMessageFrame.addShadow(color: .black, opacity: 0.5, radius: 4)
    }

}
