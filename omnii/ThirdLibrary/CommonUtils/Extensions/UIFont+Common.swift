//
//  UIFont+Common.swift
//  omnii
//
//  Created by huyang on 2023/4/24.
//

import UIKit

public extension UIFont {
    
    enum FontType: String {
        case sf                     = "SF-Pro"
        case montserratBlod         = "Montserrat-Bold"
        case montserratSemiBlod     = "Montserrat-SemiBold"
        case montserratMedium       = "Montserrat-Medium"
        case montserratExtraBold    = "Montserrat-ExtraBold"
        case montserratRegular      = "Montserrat-Regular"
        case montserratLight        = "Montserrat-Light"
        case montserratExtraLight   = "Montserrat-ExtraLight"
        case montserratBlack        = "Montserrat-Black"
        case montserratThin         = "Montserrat-Thin"
    }
    
    convenience init?(type fontType: FontType, size fontSize: CGFloat) {
        let name = fontType.rawValue
        self.init(name: name, size: fontSize)
    }
    
}
