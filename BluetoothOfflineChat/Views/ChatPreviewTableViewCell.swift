//
//  ChatPreviewTableViewCell.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 04/05/2023.
//

import UIKit

class ChatPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var lastChatMessagePreviewLabel: UILabel!
    @IBOutlet weak var lastChatMessageTimeLabel: UILabel!
    @IBOutlet weak var chatFrame: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lastChatMessagePreviewLabel.font = .systemFont(ofSize: 18, weight: .bold)
        lastChatMessagePreviewLabel.textColor = .white
        
        lastChatMessageTimeLabel.font = .systemFont(ofSize: 13, weight: .regular)
        lastChatMessageTimeLabel.textColor = .white
        
        chatFrame.layer.backgroundColor = Constants.colors.darkColor.cgColor
        chatFrame.layer.cornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
