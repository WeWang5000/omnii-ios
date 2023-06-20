//
//  String+Omnii.swift
//  omnii
//
//  Created by huyang on 2023/5/31.
//

import Foundation
import SwifterSwift

extension String {
    
    func date(with format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
}
