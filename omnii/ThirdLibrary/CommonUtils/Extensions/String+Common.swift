//
//  String+Common.swift
//  omnii
//
//  Created by huyang on 2023/4/24.
//

import Foundation
import SwiftRichString

public extension String {
    
    // objc‘s string length
    public var length: Int {
        return self.utf16.count
    }
    
    public static func singleLineHeight(font: UIFont) -> Double {
        return "Default".height(font: font)
    }
    
    public static func singleLineHeight(attributes attrs: [NSAttributedString.Key : Any]?) -> Double {
        return "Default".height(attributes: attrs)
    }
    
    // MARK: - font
    
    public func size(font: UIFont,
                     containerWidth width: Double = .greatestFiniteMagnitude,
                     containerHeight height: Double = .greatestFiniteMagnitude) -> CGSize {
        let attrs: [NSAttributedString.Key : Any] = [.font: font]
        return size(attributes: attrs, containerWidth: width, containerHeight: height)
    }
    
    public func height(font: UIFont, containerWidth width: Double = .greatestFiniteMagnitude) -> Double {
        let attrs: [NSAttributedString.Key : Any] = [.font: font]
        return size(attributes: attrs, containerWidth: width).height
    }
    
    public func width(font: UIFont, containerHeight height: Double = .greatestFiniteMagnitude) -> Double {
        let attrs: [NSAttributedString.Key : Any] = [.font: font]
        return size(attributes: attrs, containerHeight: height).width
    }
    
    
    // MARK: - style
    
    public func size(style: Style,
                     containerWidth width: Double = .greatestFiniteMagnitude,
                     containerHeight height: Double = .greatestFiniteMagnitude) -> CGSize {
        return size(attributes: style.attributes, containerWidth: width, containerHeight: height)
    }
    
    public func height(style: Style, containerWidth width: Double = .greatestFiniteMagnitude) -> Double {
        return size(style: style, containerWidth: width).height
    }
    
    public func width(style: Style, containerHeight height: Double = .greatestFiniteMagnitude) -> Double {
        return size(style: style, containerHeight: height).width
    }
    
    
    // MARK: - attributes
    
    //  for example:
    //  let font = UIFont(type: .montserratBlod, size: 25.rpx)
    //  let color = UIColor.white.withAlphaComponent(0.3)
    //  let kern = 0.5
    //  let attrs: [NSAttributedString.Key : Any] = [.font: font!,
    //                                               .foregroundColor: color,
    //                                               .kern: kern]
    public func size(attributes attrs: [NSAttributedString.Key : Any]?,
                     containerWidth width: Double = .greatestFiniteMagnitude,
                     containerHeight height: Double = .greatestFiniteMagnitude) -> CGSize {
        let attrStr = NSAttributedString(string: self, attributes: attrs)
        
        let rect = attrStr.boundingRect(with: CGSize(width: width,
                                                     height: height),
                                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                                        context: nil)
        return CGSize(width: ceil(rect.size.width), height: ceil(rect.size.height))
    }
    
    public func height(attributes attrs: [NSAttributedString.Key : Any]?,
                       containerWidth width: Double = .greatestFiniteMagnitude) -> Double {
        return size(attributes: attrs, containerWidth: width).height
    }
    
    public func width(attributes attrs: [NSAttributedString.Key : Any]?,
                      containerHeight height: Double = .greatestFiniteMagnitude) -> Double {
        return size(attributes: attrs, containerHeight: height).width
    }
    
}


public extension NSAttributedString {
    
    public func size(containerWidth width: Double = .greatestFiniteMagnitude,
                     containerHeight height: Double = .greatestFiniteMagnitude) -> CGSize {
        
        let rect = self.boundingRect(with: CGSize(width: width, height: height),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return CGSize(width: ceil(rect.size.width), height: ceil(rect.size.height))

    }

    public func height(containerWidth width: Double = .greatestFiniteMagnitude) -> Double {
        return size(containerWidth: width).height
    }

    public func width(containerHeight height: Double = .greatestFiniteMagnitude) -> Double {
        return size(containerHeight: height).width
    }
}
