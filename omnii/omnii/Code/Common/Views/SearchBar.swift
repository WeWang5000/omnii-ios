//
//  SearchBar.swift
//  omnii
//
//  Created by huyang on 2023/5/19.
//

import UIKit
import CommonUtils

class SearchBar: UIView {
    
    var textChanged: ((String) -> Void)?
    var returnHandler: ((String?) -> Void)?
    
    private(set) var textField: UITextField!
    private var imageView: UIImageView!
    private var clearButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.do {
            let size = CGSize(width: 28.rpx, height: 28.rpx)
            let x = 16.rpx
            let y = (self.height - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        }
        
        clearButton.do {
            let size = CGSize(width: 30.rpx, height: 30.rpx)
            let x = self.width - 12.rpx - size.width
            let y = (self.height - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        }
        
        textField.do {
            let x = imageView.frame.maxX + 12.rpx
            let y = 0.0
            let width = clearButton.x - x - 12.rpx
            let height = self.height
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
    }
    
    private func setupViews() {
        
        imageView = UIImageView().then {
            $0.image = UIImage(named: "search_icon")
            $0.contentMode = .scaleAspectFit
        }
        
        clearButton = UIButton(imageName: "search_clear").then {
            $0.isHidden = true
        }
        clearButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        textField = UITextField().then {
            $0.placeholder = "Search"
            $0.textColor = .white
            $0.font = UIFont(type: .montserratRegular, size: 15.rpx)
            $0.textAlignment = .left
            $0.tintColor = UIColor(hexString: "#5367E2")
            $0.delegate = self
        }
        
        addSubviews([imageView, clearButton, textField])
    }
    
    @objc private func click(_ sender: UIButton) {
        clear()
    }

    private func clear() {
        textField.text = ""
        textChanged?("")
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
}


extension SearchBar: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else {
            clearButton.isHidden = true
            textChanged?("")
            return
        }
        clearButton.isHidden = (text == "")
        textChanged?(textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        returnHandler?(textField.text)
        textField.resignFirstResponder()
        return true
    }
    
}
