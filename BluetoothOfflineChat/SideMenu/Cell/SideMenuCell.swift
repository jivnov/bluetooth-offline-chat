//
//  SideMenuCell.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 08/05/2023.
//

import UIKit

class SideMenuCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        self.iconImageView.tintColor = .white
        
        self.titleLabel.textColor = .white
    }
}
