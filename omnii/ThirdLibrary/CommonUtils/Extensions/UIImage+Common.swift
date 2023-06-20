//
//  UIImage+Common.swift
//  omnii
//
//  Created by huyang on 2023/5/9.
//

import UIKit
import SwifterSwift

public extension UIImage {
    
    convenience init(color: UIColor, size: CGSize, scale: CGFloat) {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        defer {
            UIGraphicsEndImageContext()
        }

        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }

        self.init(cgImage: aCgImage)
    }
    
    // scale: width / height
    // e.g. 9 / 16
    func cropped(scale: Double = (9.0 / 16.0)) -> UIImage {
        
        let actualScale = size.width / size.height
        
        if actualScale == scale { return self }
        
        if actualScale < scale {
            
            let newHeight = size.width *  (1.0 / scale)
            let y = (size.height - newHeight) / 2.0
            return cropped(to: CGRect(x: 0, y: y, width: size.width, height: newHeight))
            
        } else {
            
            let newWidth = size.height * scale
            let x = (size.width - newWidth) / 2.0
            return cropped(to: CGRect(x: x, y: 0, width: newWidth, height: size.height))
            
        }
        
    }
    
    func alpha(_ value: Double) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
