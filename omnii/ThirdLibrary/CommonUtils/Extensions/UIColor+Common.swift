//
//  UIColor+Common.swift
//  omnii
//
//  Created by huyang on 2023/5/6.
//

import UIKit
import SwifterSwift

public extension UIColor {
    
    enum GradientDirection {
        /// gradient left to right.
        case horizontal
        
        /// gradient up to down.
        case vertical
    }
    
    convenience init(gradientColors colors: [UIColor], bounds: CGRect, direction: GradientDirection = .horizontal) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map{$0.cgColor}
        
        switch direction {
        case .horizontal:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        case .vertical:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        }
        
        gradientLayer.frame = bounds
        UIGraphicsBeginImageContext(bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let img = image {
            self.init(patternImage: img)
        } else {
            self.init()
        }
        
    }
    
}
