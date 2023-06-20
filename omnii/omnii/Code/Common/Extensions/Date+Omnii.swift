//
//  Date+Omnii.swift
//  omnii
//
//  Created by huyang on 2023/5/28.
//

import Foundation
import SwifterSwift

extension Date {
    
    func invitesTime() -> (String, String) {
        
        var dayName = ""
        if self.isInToday {
            dayName = "Today"
        } else if self.isInTomorrow {
            dayName = "Tomorrow"
        } else {
            let monthName = self.monthName(ofStyle: .threeLetters)
            dayName = monthName + "\(self.day)"
        }
        
        let hourName = hourIntervalString()
        
        return (dayName, hourName)
    }
    
    func hourIntervalString() -> String {
        let currentHour = self.hour
        return currentHour.hour24To12()
    }
    
    func discoverDateString() -> String {
        
        guard isInCurrentYear else {
            return string(withFormat: "yyyy-MM-dd")
        }
        
        if isInYesterday {
            return "Ye. " + string(withFormat: "HH:mm")
        }
        
        if isInToday {
            
            let diff = abs(self.timeIntervalSinceNow)

            if diff < 60 {
                return "\(Int(diff)) second ago"
            }
            
            if diff < 3600 {
                return "\(Int(diff / 60)) minute ago"
            }
            
            return "\(Int(diff / 3600)) hour ago"
        }
        
        return string(withFormat: "MM-dd")
    }
    
    // 邀请页面，时间选择器数据源
    func invitesDateItems() -> [InvitesDateItem] {
        var items = [InvitesDateItem]()
        
        items.append(InvitesDateItem(year: self.year,
                                     month: self.month,
                                     day: self.day,
                                     hour: self.hour,
                                     minute: self.minute))
        
        for i in 1...30 {
            let some = self.adding(.day, value: i)
            items.append(InvitesDateItem(year: some.year,
                                         month: some.month,
                                         day: some.day,
                                         hour: .zero,
                                         minute: .zero))
        }
        
        return items
    }
    
}

private extension Int {
    
    func hour24To12() -> String {
        if self == 24 { return "0AM" }
        return self > 12 ? "\(self - 12)PM" : "\(self)AM"
    }
    
}
