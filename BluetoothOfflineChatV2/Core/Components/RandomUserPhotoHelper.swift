//
//  RandomUserPhotoHelper.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 06/02/2024.
//

import Foundation
import SwiftUI

struct RandomUserPhotoHelper {
    static func randomColor() -> Color {
        return Color(red: randomAmount(), green: randomAmount(), blue: randomAmount())
    }
    
    private static func randomAmount() -> Double {
        return Double(arc4random()) / CGFloat(UInt32.max)
    }
    
    static func isLight(color: Color, threshold: Float = 0.65) -> Bool {
        let uicolor = UIColor(color)
        let originalCGColor = uicolor.cgColor

        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return false
        }
        guard components.count >= 3 else {
            return false
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}
