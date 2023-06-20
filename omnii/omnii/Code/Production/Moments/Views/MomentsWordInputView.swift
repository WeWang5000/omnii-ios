//
//  MomentsWordInputView.swift
//  omnii
//
//  Created by huyang on 2023/5/11.
//

import UIKit
import CommonUtils
import SwifterSwift

class MomentsWordInputView: UIView {
    
    var completion: ((String) -> Void)?
    
    private var textView: UITextView!
    private var countLabel: UILabel!
    private var doneButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        alpha = 0.0
        backgroundColor = .black.withAlphaComponent(0.4)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHidden: Bool {
        didSet {
            isHidden ? dismiss() : show()
        }
    }
    
}

private extension MomentsWordInputView {
    
    func setupViews() {
        
        textView = UITextView().then {
            $0.isScrollEnabled = false
            $0.textContainerInset = UIEdgeInsets(top: 18.0, left: 30.0, bottom: 18.0, right: 30.0)
            $0.textContainer.lineFragmentPadding = 0
            $0.layoutManager.allowsNonContiguousLayout = false
            $0.backgroundColor = .black.withAlphaComponent(0.5)
            $0.cornerRadius = 15.0
            $0.textAlignment = .center
            $0.font = UIFont(type: .montserratRegular, size: 18.0)
            $0.textColor = .white
            $0.tintColor = UIColor(hexString: "#5367E2")
            $0.keyboardAppearance = .dark
            $0.delegate = self
            
            let width = 90.0
            let height = 60.0
            let x = (ScreenWidth - width) / 2.0
            let y = 283.5
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        countLabel = UILabel().then {
            $0.text = "0/100"
            $0.textColor = .white
            $0.font = UIFont(type: .montserratRegular, size: 13)
            $0.textAlignment = .right
            $0.isHidden = true
        }
                
        doneButton = UIButton(type: .custom).then {
            let size = CGSize(width: 70.0, height: 40.0)
            let x = ScreenWidth - size.width - 20.0
            let y = 65.0
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            let image = UIImage(color: .black.withAlphaComponent(0.4), size: size)
            $0.setBackgroundImage(image, for: .normal)
            $0.setTitleForAllStates("Done")
            $0.setTitleColorForAllStates(.white)
            $0.cornerRadius = size.height / 2.0
            $0.titleLabel?.font = UIFont(type: .montserratMedium, size: 16.0)
        }
        
        doneButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        addSubview(textView)
        addSubview(countLabel)
        addSubview(doneButton)
    }
    
    @objc private func click(_ sender: UIButton) {
        dismiss()
    }
    
    private func show() {
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.alpha = 1.0
        } completion: { _ in
            self.textView.becomeFirstResponder()
        }
    }
    
    private func dismiss() {
        self.textView.resignFirstResponder()
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.alpha = 0.0
        } completion: { _ in
            guard let handler = self.completion else { return }
            handler(self.textView.text)
        }
    }
    
}


extension MomentsWordInputView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.length > 0 {
            if textView.text.length + text.length > 100 {
                return false
            }
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        countLabel.text = "\(textView.text.length)/100"
        layoutTextView(for: textView.text)
        layoutCountLabel()
    }
    
    func layoutTextView(for text: String) {
        let insets = UIEdgeInsets(top: 18.0, left: 30.0, bottom: 18.0, right: 30.0)
        
        let minWidth = 90.0
        let maxWidth = ScreenWidth - 40.0
        
        let minHeight = 55.0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.05
        let attrs: [NSAttributedString.Key : Any] = [.font: textView.font!,
                                                     .paragraphStyle: paragraphStyle]
        
        var width = textView.width
        var height = textView.height
        
        let size = text.size(attributes: attrs)
        let newWidth = size.width + insets.horizontal
        let newHeight = size.height + insets.vertical
        
        if newWidth >= maxWidth {
            
            countLabel.isHidden = false
            textView.textAlignment = .left
            width = maxWidth
            height = text.height(attributes: attrs, containerWidth: maxWidth - insets.horizontal) + insets.vertical
            
        } else {
            
            countLabel.isHidden = true
            textView.textAlignment = .center
            width = max(newWidth, minWidth)
            height = max(newHeight, minHeight)
            
        }
        
        let x = (ScreenWidth - width) / 2.0
        let y = 283.5
        textView.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    func layoutCountLabel() {
        let size = CGSize(width: 100.0, height: 15.0)
        let x = ScreenWidth - 31.0 - size.width
        let y = textView.frame.maxY + 10.0
        countLabel.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
}
