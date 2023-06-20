//
//  SignupTextField.swift
//  omnii
//
//  Created by huyang on 2023/4/24.
//

import UIKit

class SignupTextField: UITextField {
    
    private var offset: UIOffset
    
    init(frame: CGRect, offset: UIOffset = .zero) {
        self.offset = offset
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        if offset != .zero {
            return CGRectInset(bounds, offset.horizontal, offset.vertical)
        }
        return super.textRect(forBounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        if offset != .zero {
            return CGRectInset(bounds, offset.horizontal, offset.vertical)
        }
        return super.editingRect(forBounds: bounds)
    }
    
    
    
}
