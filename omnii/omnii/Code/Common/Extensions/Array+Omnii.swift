//
//  Array+Omnii.swift
//  omnii
//
//  Created by huyang on 2023/5/24.
//

import UIKit

extension Array where Element == UIButton {
    
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        self.forEach { $0.addTarget(target, action: action, for: controlEvents) }
    }
    
}
