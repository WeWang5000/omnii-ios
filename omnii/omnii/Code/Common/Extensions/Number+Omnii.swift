//
//  Number+Omnii.swift
//  omnii
//
//  Created by huyang on 2023/6/3.
//

import Foundation

extension SignedInteger {
    
    func countFormat() -> String {
        if self >= 10000 {
            return "\(self / 1000)K"
        }
        return "\(self)"
    }
    
}

extension Double {
    
    func toInvitesDistance() -> String {
        if self >= 1000 {
            return "\(Int(self / 1000))km"
        }
        return "\(self)m"
    }
    
}
