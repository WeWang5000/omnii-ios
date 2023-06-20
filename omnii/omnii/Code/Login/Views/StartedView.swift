//
//  StartedView.swift
//  omnii
//
//  Created by huyang on 2023/5/4.
//

import UIKit
import CommonUtils

class StartedView: UIView {
    
    var actionHandler: (() -> Void)?
    
    private let title = "Welcome to Omnii"
    private let subTitle = "You've Successfully Registered!"
    
    private var titleLabel: UILabel!
    private var subTitleLabel: UILabel!
    private var imageView: UIImageView!
    private var btn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension StartedView {
    
    func setupViews() {
        layer.setImage(UIImage(named: "welcome_bg"))
        
        titleLabel = UILabel()
        titleLabel.font = UIFont(type: .montserratBlod, size: 28)
        titleLabel.text = title
        titleLabel.textColor = .white
        let titleH = 30.rpx
        let titleW = titleWidth(containerHeight: titleH)
        let titleX = (ScreenWidth - titleW) / 2.0
        let titleY = 110.rpx
        titleLabel.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
        
        imageView = UIImageView()
        imageView.image = UIImage(named: "welcome_earth")
        imageView.contentMode = .scaleAspectFill
        let imgW = 325.rpx
        let imgH = 325.rpx
        let imgX = (ScreenWidth - imgW) / 2.0
        let imgY = 170.rpx
        imageView.frame = CGRect(x: imgX, y: imgY, width: imgW, height: imgH)
        
        subTitleLabel = UILabel()
        subTitleLabel.font = UIFont(type: .montserratBlod, size: 15.rpx)
        subTitleLabel.text = subTitle
        subTitleLabel.textColor = UIColor(hexString: "#E6E9FF")!
        let subTitleH = 30.rpx
        let subTitleW = subTitleWidth(containerHeight: subTitleH)
        let subTitleX = (ScreenWidth - subTitleW) / 2.0
        let subTitleY = imageView.frame.maxY + 22.rpx
        subTitleLabel.frame = CGRect(x: subTitleX, y: subTitleY, width: subTitleW, height: subTitleH)
        
        btn = UIButton(type: .custom)
        btn.setTitleForAllStates("Get Started")
        btn.setBackgroundImage(UIImage(named: "welcome_btn"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(type: .montserratBlod, size: 20.rpx)
        let btnW = 320.rpx
        let btnH = 60.rpx
        let btnX = (ScreenWidth - btnW) / 2.0
        let btnY = subTitleLabel.frame.maxY + 30.rpx
        btn.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnH)
        
        btn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
                
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(subTitleLabel)
        addSubview(btn)
    }
    
    @objc private func click(_ sender: UIButton) {
        if let action = self.actionHandler {
            action()
        }
    }
    
    func titleWidth(containerHeight: Double) -> Double {
        let font = titleLabel.font
        let attrs: [NSAttributedString.Key : Any] = [.font: font!]
        return title.width(attributes: attrs, containerHeight: containerHeight)
    }
    
    func subTitleWidth(containerHeight: Double) -> Double {
        let font = subTitleLabel.font
        let attrs: [NSAttributedString.Key : Any] = [.font: font!]
        return subTitle.width(attributes: attrs, containerHeight: containerHeight)
    }
    
}
