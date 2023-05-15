//
//  UIView+Extension.swift
//  BluetoothOfflineChat
//
//  Created by Andrei Zhyunou on 04/05/2023.
//

import UIKit
import Foundation

extension UIView {
    func rotate() {
        let rotation : CABasicAnimation = CASpringAnimation(keyPath: "transform.rotation")
        
        
        rotation.fromValue = 0.0
        rotation.toValue = NSNumber(value: Double.pi * 1.5)
        rotation.duration = 1.0
        rotation.isCumulative = true
        
        rotation.repeatCount = Float.infinity
        self.layer.add(rotation, forKey: "transform.rotation")
    }
    
    func addShadow(color: UIColor, opacity: Float, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
    }
}
