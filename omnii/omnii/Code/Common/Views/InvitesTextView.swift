//
//  InvitesTextView.swift
//  omnii
//
//  Created by huyang on 2023/5/25.
//

import UIKit
import CommonUtils
import SwiftRichString

final class InvitesTextView: UIView {
    
    var textDidChange: ((String) -> Void)?
    var heightChanged: ((Double) -> Void)?

    var text: String {
        get { textView.attributedText.string }
        set {
            let style = Style {
                $0.font = UIFont(type: .montserratBlod, size: 25.rpx)
                $0.lineHeightMultiple = 1.31
                $0.color = Color(hexString: "FFFFFF")
                $0.alignment = .left
            }
            textView.attributedText = newValue.set(style: style)
            layoutContentView(for: newValue)
        }
    }
    
    var isHiddenLimitLabel: Bool {
        get { countLabel.isHidden }
        set { countLabel.isHidden = newValue }
    }
    
    var isEnabled: Bool {
        get { textView.isEditable }
        set { textView.isEditable = newValue }
    }
    
    var typingAttributes: [NSAttributedString.Key : Any] {
        get { textView.typingAttributes }
    }
    
    private var textView: CustomTextView!
    private var placeholderLabel: UILabel!
    private var countLabel: UILabel!
    
    private let placeholder: String
    private let originHeight: Double
    private let textInsets: UIEdgeInsets
    private let maxHeight: Double
    private let showLimitLabel: Bool
    private let limitCount: Int
    
    required init(frame: CGRect,
                  placeholder: String = "",
                  showLimitLabel: Bool = false,
                  limitCount: Int = 100,
                  maxHeight: Double = .greatestFiniteMagnitude,
                  textInsets: UIEdgeInsets = .zero) {
        self.placeholder = placeholder
        self.originHeight = frame.height
        self.showLimitLabel = showLimitLabel
        self.limitCount = limitCount
        self.textInsets = textInsets
        self.maxHeight = maxHeight
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeFirstResponder: Bool {
        return textView.canBecomeFirstResponder
    }
    
    override var canResignFirstResponder: Bool {
        return textView.canResignFirstResponder
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    private func setupViews() {
        
        countLabel = UILabel().then {
            if self.showLimitLabel {
                $0.text = "0/\(self.limitCount)"
            }
            $0.textColor = .white
            $0.font = UIFont(type: .montserratRegular, size: 13)
            $0.textAlignment = .right
            let height = $0.text?.height(font: $0.font) ?? 0.0
            let width = self.width - 20.rpx
            let x = 10.rpx
            let y = self.height - height
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        textView = CustomTextView().then {
            let style = Style {
                $0.font = UIFont(type: .montserratBlod, size: 25.rpx)
                $0.lineHeightMultiple = 1.31
                $0.color = Color(hexString: "FFFFFF")
                $0.alignment = .left
            }
            $0.typingAttributes = style.attributes
            $0.backgroundColor = .clear
            $0.tintColor = UIColor(hexString: "#5367E2")
            $0.isScrollEnabled = false
            $0.textContainerInset = self.textInsets
            $0.textContainer.lineFragmentPadding = 0
            $0.layoutManager.allowsNonContiguousLayout = false
            $0.delegate = self
            let x = 0.0
            let y = 0.0
            let width = self.width
            let height = self.height - countLabel.height
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        placeholderLabel = UILabel().then {
            let style = Style {
                $0.font = UIFont(type: .montserratBlod, size: 30.rpx)
                $0.lineHeightMultiple = 0.96
                $0.color = Color(hexString: "FFFFFF", transparency: 0.4)
                $0.alignment = .left
            }
            $0.attributedText = placeholder.set(style: style)
            $0.numberOfLines = 0
            let origin = CGPoint(x: 10.rpx, y: 10.rpx)
            let size = placeholder.size(style: style)
            $0.frame = CGRect(origin: origin, size: size)
        }
        
        addSubview(textView)
        addSubview(countLabel)
        textView.addSubview(placeholderLabel)
    }
    
    private func layoutContentView(for text: String) {
        
        let atts = self.textView.typingAttributes
        let width = textView.width + self.textInsets.horizontal
        let height = text.height(attributes: atts, containerWidth: width)
        let newHeight = max((height + self.textInsets.vertical), (originHeight - countLabel.height))
        
        countLabel.isHidden = false
        textView.textAlignment = .left
        
        guard Int(newHeight) != Int(textView.height) else { return }
        
        textView.isScrollEnabled = maxHeight.isLessThanOrEqualTo(newHeight + self.countLabel.height)
        if textView.isScrollEnabled { return }
        
        UIView.animate(withDuration: 0.15) {
            self.height = newHeight + self.countLabel.height
            self.textView.height = newHeight
            self.countLabel.y = newHeight
            self.heightChanged?(newHeight)
        }
        
    }
    
}

extension InvitesTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        countLabel.text = "\(textView.text.count)/\(self.limitCount)"
        textDidChange?(textView.text)
        layoutContentView(for: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text.length > 0 {
            if textView.text.length + text.length > self.limitCount {
                return false
            }
        }
        
        return true
    }
    
}


private class CustomTextView: UITextView {
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.height = 40.rpx
        return rect
    }
    
}
