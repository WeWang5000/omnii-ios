//
//  UIColor+Omnii.swift
//  omnii
//
//  Created by huyang on 2023/5/25.
//

import UIKit

extension UIColor {
    
    static func textGradient(size: CGSize) -> UIColor {
        let start = UIColor(hexString: "#26F8FF")
        let end = UIColor(hexString: "#9F33FE")
        return UIColor(gradientColors: [start, end], bounds: CGRect(origin: .zero, size: size))
    }
    
    static func blackVerticalGradient(size: CGSize) -> UIColor {
        let start = UIColor(hexString: "#1C1C1C")
        let end = UIColor(hexString: "#323232")
        return UIColor(gradientColors: [start, end], bounds: CGRect(origin: .zero, size: size), direction: .vertical)
    }
    
    static func discoverCardGradient(size: CGSize) -> UIColor {
        let start = UIColor.white.withAlphaComponent(0.15)
        let end = UIColor.white.withAlphaComponent(0.07)
        return UIColor(gradientColors: [start, end], bounds: CGRect(origin: .zero, size: size), direction: .vertical)
    }
    
    static func discoverNavigationShadowGradient(size: CGSize) -> UIColor {
        let start = UIColor.black.withAlphaComponent(0.5)
        let end = UIColor.clear
        return UIColor(gradientColors: [start, end], bounds: CGRect(origin: .zero, size: size), direction: .vertical)
    }
    
    static func purpleVerticalGradient(size: CGSize) -> UIColor {
        let start = UIColor(hexString: "#F533FE")
        let mid = UIColor(hexString: "#9033FE")
        let end = UIColor(hexString: "#5433FE")
        return UIColor(gradientColors: [start, mid, end], bounds: CGRect(origin: .zero, size: size), direction: .vertical)
    }
    
}
