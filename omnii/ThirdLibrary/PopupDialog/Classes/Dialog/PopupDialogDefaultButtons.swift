//
//  PopupDialogDefaultButtons.swift
//
//  Copyright (c) 2016 Orderella Ltd. (http://orderella.co.uk)
//  Author - Martin Wildfeuer (http://www.mwfire.de)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

// MARK: Default button

/// Represents the default button for the popup dialog
public final class DefaultButton: PopupDialogButton {}

// MARK: Cancel button

/// Represents a cancel button for the popup dialog
public final class CancelButton: PopupDialogButton {

    override public func setupView() {
        defaultTitleColor = UIColor.lightGray
        super.setupView()
    }
    
}

// MARK: destructive button

/// Represents a destructive button for the popup dialog
public final class DestructiveButton: PopupDialogButton {

    override public func setupView() {
        defaultTitleColor = UIColor.red
        super.setupView()
    }
    
}

// MARK: gradient button

public final class GradientButton: PopupDialogButton {
    
    public override func setupView() {
        if let title = titleForNormal {
            defaultTitleFont = UIFont(type: .montserratBlod, size: 18.rpx)
            
            let attrs: [NSAttributedString.Key : Any] = [.font: defaultTitleFont!]
            let size = title.size(attributes: attrs)
            let start = UIColor(hexString: "#26F8FF")!
            let end = UIColor(hexString: "#9F33FE")!
            defaultTitleColor = UIColor(gradientColors: [start, end], bounds: CGRect(origin: .zero, size: size))
        }
        super.setupView()
    }
    
}
