//
//  DigitalFit.swift
//  omnii
//
//  Created by huyang on 2023/4/20.
//

import UIKit

fileprivate let reference_width = 375.0
fileprivate let screen_width = UIScreen.main.bounds.width

public class DigitalFit {
    
    static var ratio: Double = {
        return screen_width / reference_width
    }()
    
    static func fitInt(_ value: Int) -> Double {
        return ratio * Double(value)
    }
    
    static func fitDoule(_ value: Double) -> Double {
        return ratio * value
    }
    
    static func fitFloat(_ value: Float) -> Double {
        return ratio * Double(value)
    }
    
    static func fitCGFloat(_ value: CGFloat) -> Double {
        return ratio * value
    }
    
}


public extension Int {
    
    var rpx: Double {
        return DigitalFit.fitInt(self)
    }

}


public extension Float {
    
    var rpx: Double {
        return DigitalFit.fitFloat(self)
    }
    
}


public extension Double {
    
    var rpx: Double {
        return DigitalFit.fitDoule(self)
    }
    
}


public extension CGFloat {
    
    var rpx: Double {
        return DigitalFit.fitCGFloat(self)
    }
    
}
