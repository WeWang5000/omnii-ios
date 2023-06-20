//
//  ScreentFit+Omnii.swift
//  omnii
//
//  Created by huyang on 2023/6/14.
//

import UIKit
import CommonUtils

extension ScreenFit {
    
    public static var omniiNavigationBarHeight: CGFloat = {
        return 70.rpx
    }()
    
    public static var omniiNavigationHeight: CGFloat = {
        return omniiNavigationBarHeight + statusBarHeight
    }()
    
}
