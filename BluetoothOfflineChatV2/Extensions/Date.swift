//
//  Date.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 26/01/2024.
//

import Foundation

extension Date {
    func timestampString() -> String {
        if Calendar.current.isDateInToday(self) {
            return timeString()
        } else if Calendar.current.isDateInYesterday(self) {
            return String(localized: "Yesterday")
        } else {
            return dateString()
        }
    }
    
    func timestampFullString() -> String {
        return "\(dateString()) \(timeString())"
    }
    
    func timestampDateToString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = encodingDateFormat()
        return formatter.string(from: self)
    }
    
    func timestampDate(from str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = encodingDateFormat()
        return formatter.date(from: str)
    }
    
    private func encodingDateFormat() -> String {
        return "YY-MMM-d HH:mm:ss"
    }
    
    private func timeString() -> String {
        return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
    }
    
    private func dateString() -> String {
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }
}
