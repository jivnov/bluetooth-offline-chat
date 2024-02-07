//
//  Date.swift
//  BluetoothOfflineChatV2
//
//  Created by jivnov on 26/01/2024.
//

import Foundation

extension Date {
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }
    
    private func timeString() -> String {
        return timeFormatter.string(from: self)
    }
    
    private func dateString() -> String {
        return dayFormatter.string(from: self)
    }
    
    func timestampString() -> String {
        if Calendar.current.isDateInToday(self) {
            return timeString()
        } else if Calendar.current.isDateInYesterday(self) {
            return String(localized: "Yesterday")
        } else {
            return dateString()
        }
    }
    
    func timestampDateToString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YY-MMM-d HH:mm:ss"
        return formatter.string(from: self)
    }
    
    func timestampDate(from str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "YY-MMM-d HH:mm:ss"
        return formatter.date(from: str)
    }
}
