//
//  LoginView.swift
//  omnii
//
//  Created by huyang on 2023/4/20.
//

import UIKit
import CommonUtils
import SwifterSwift

fileprivate struct Constant {
    let appleBtnMaxY = 152.rpx
    let appleBtnImage = UIImage(named: "login_apple")
    let appleBtnTitle = "Continue with Apple"
    
    let phoneBtnImage = UIImage(named: "login_phone")
    let phoneBtnTitle = "Continue with Phone"
    
    let phoneBtnBottomMargin = 10.rpx
    let appleBtnBottomMargin = 20.rpx
    
    let tagLabelFont = UIFont(type: .montserratLight, size: 12.rpx)
    let tagLabelSize = CGSize(width: 273.rpx, height: 30.rpx)
    let tagLabelTextColor = UIColor.white
    let tagLabelText = "By joining Omnii,you agree to \"Omnii Terms of Service\"&\"Omnii Privacy Policy\""
}

class LoginView: UIView {
    
    enum LoginViewActionType {
        case apple
        case phone
    }
    
    typealias Handler = (_ type: LoginViewActionType) -> Void
    var actionHandler: Handler?
    
    private var appleBtn: UIButton!
    private var phoneBtn: UIButton!
    
    private var constant: Constant!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constant = Constant()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        appleBtn = loginButton(image: constant.appleBtnImage, title: constant.appleBtnTitle)
        appleBtn.x = (ScreenWidth - appleBtn.width) / 2.0
        appleBtn.y = ScreenHeight - constant.appleBtnMaxY - appleBtn.height
                
        phoneBtn = loginButton(image: constant.phoneBtnImage, title: constant.phoneBtnTitle)
        phoneBtn.x = (ScreenWidth - phoneBtn.width) / 2.0
        phoneBtn.y = appleBtn.frame.minY - constant.phoneBtnBottomMargin - phoneBtn.height
        
        appleBtn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        phoneBtn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        let tagLabel = UILabel()
        tagLabel.numberOfLines = 0
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attr: [NSAttributedString.Key : Any] = [.font: constant.tagLabelFont ?? UIFont.systemFont(ofSize: 12.rpx),
                                                    .foregroundColor: constant.tagLabelTextColor,
                                                    .paragraphStyle: paragraph]
        let attrString = NSMutableAttributedString(string: constant.tagLabelText)
        attrString.addAttributes(attr, range: NSRange(location: 0, length: attrString.length))
        tagLabel.attributedText = attrString
        tagLabel.size = constant.tagLabelSize
        tagLabel.x = (ScreenWidth - tagLabel.width) / 2.0
        tagLabel.y = appleBtn.frame.maxY + constant.appleBtnBottomMargin
        
        addSubview(appleBtn)
        addSubview(phoneBtn)
        addSubview(tagLabel)
    }
    
    private func loginButton(image: UIImage?, title: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.size = CGSize(width: 320.rpx, height: 60.rpx)
        btn.titleLabel?.font = UIFont(type: .montserratBlod, size: 15.rpx)
        btn.setTitleForAllStates(title)
        btn.backgroundColor = .white
        btn.cornerRadius = btn.height / 2.0
        btn.setTitleColorForAllStates(UIColor(hexString: "#010101")!)
        btn.setBackgroundImage(UIImage(color: .white, size: btn.size), for: .normal)
        btn.setBackgroundImage(UIImage(color: UIColor(hexString: "#F5F5F5")!, size: btn.size), for: .highlighted)
        if let img = image {
            btn.setImageForAllStates(img)
        }
        btn.centerTextAndImage(spacing: 10.rpx)
        return btn
    }
    
    @objc private func click(_ sender: UIButton) {
        guard let handle = actionHandler else { return }
        if sender == appleBtn {
            handle(.apple)
        } else {
            handle(.phone)
        }
    }

}
