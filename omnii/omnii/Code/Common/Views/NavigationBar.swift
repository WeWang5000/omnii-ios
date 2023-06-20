//
//  NavigationBar.swift
//  omnii
//
//  Created by huyang on 2023/5/19.
//

import UIKit
import CommonUtils

class NavigationBar: UIView {
    
    enum BackStyle {
        case back
        case close
    }
    
    var backAction: (() -> Void)?
    var rightItemAction: (() -> Void)?
    
    var isBackHidden: Bool {
        get { return backButton.isHidden }
        set { backButton.isHidden = newValue }
    }
    
    var isRightButtonHidden: Bool {
        get { return rightButton.isHidden }
        set { rightButton.isHidden = newValue }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var adjustContentVertical: Double {
        get { return contentVertical }
        set {
            contentVertical = newValue
            layoutIfNeeded()
        }
    }
    
    var backStyle: BackStyle = .back {
        didSet {
            switch backStyle {
            case .back:
                updateBackButton(imageName: "back")
            case .close:
                updateBackButton(imageName: "camera_close")
            }
        }
    }
    
    private var contentVertical: Double = .zero
    private var buttonBackgroudColor: UIColor = .white.withAlphaComponent(0.1)
    
    private var contentView: UIView!
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    private var rightButton: UIButton!
    
    required init(size: CGSize = CGSize(width: ScreenWidth, height: ScreenFit.omniiNavigationHeight)) {
        super.init(frame: CGRect(origin: .zero, size: size))
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateBackButton(imageName: String? = nil, title: String? = nil, imageAlign: UIButton.ImageAlign = .left(5.0)) {
        backButton.updateButton(imageName: imageName, title: title, imageAlign: imageAlign)
        layoutIfNeeded()
    }
    
    func updateRightButton(imageName: String? = nil, title: String? = nil, imageAlign: UIButton.ImageAlign = .left(5.0)) {
        self.rightButton.isHidden = false
        rightButton.updateButton(imageName: imageName, title: title, imageAlign: imageAlign)
        layoutIfNeeded()
    }
    
    func setButtonBackgroudColor(_ color: UIColor, for state: UIControl.State = .normal) {
        buttonBackgroudColor = color
        backButton.setRoundBackgroundColor(color, for: state)
        rightButton.setRoundBackgroundColor(color, for: state)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.do {
            let x = 0.0
            let y = ScreenFit.statusBarHeight
            let width = ScreenWidth
            let height = self.height - y
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        backButton.do {
            var width = 12.rpx
            if let title = $0.titleForNormal {
                let attrs: [NSAttributedString.Key : Any] = [.font: $0.titleLabel!.font!]
                width += title.width(attributes: attrs, containerHeight: 16.rpx) + 12.rpx
            }
            if let _ = $0.imageForNormal {
                width += 28.rpx
            }
            let size = CGSize(width: width, height: 40.rpx)
            let x = 20.rpx
            let y = (contentView.height - size.height) / 2.0 + contentVertical
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            $0.setRoundBackgroundColor(buttonBackgroudColor, for: .normal)
        }
        
        rightButton.do {
            var width = 12.rpx
            if let title = $0.titleForNormal {
                let attrs: [NSAttributedString.Key : Any] = [.font: $0.titleLabel!.font!]
                width += title.width(attributes: attrs, containerHeight: 16.rpx) + 12.rpx
            }
            if let _ = $0.imageForNormal {
                width += 28.rpx
            }
            let size = CGSize(width: width, height: 40.rpx)
            let x = ScreenWidth - 20.rpx - size.width
            let y = (contentView.height - size.height) / 2.0 + contentVertical
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            $0.setRoundBackgroundColor(buttonBackgroudColor, for: .normal)
        }
        
        titleLabel.do {
            let height = String.singleLineHeight(font: $0.font)
            let width = rightButton.x - backButton.frame.maxX - 40.rpx
            let x = (ScreenWidth - width) / 2.0
            let y = (contentView.height - height) / 2.0 + contentVertical
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
    }
    
    private func setupViews() {
        
        contentView = UIView()
        
        backButton = UIButton(imageName: "back")
        backButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        rightButton = UIButton(type: .custom).then {
            $0.isHidden = true
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
        }
        rightButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        titleLabel = UILabel().then {
            $0.textColor = .white
            $0.textAlignment = .center
            $0.font = UIFont(type: .montserratSemiBlod, size: 20.rpx)
        }
        
        contentView.addSubviews([backButton, rightButton, titleLabel])
        addSubview(contentView)
    }
    
    @objc private func click(_ sender: UIButton) {
        if sender == backButton {
            backAction?()
        } else if sender == rightButton {
            rightItemAction?()
        }
    }
    
}

private extension UIButton {
    
    func updateButton(imageName: String?, title: String?, imageAlign: UIButton.ImageAlign) {
        if let title = title {
            setTitleForAllStates(title)
            titleLabel?.font = UIFont(type: .montserratMedium, size: 16.rpx)
        } else {
            removeTitleForAllStates()
        }
        
        if let imageName = imageName {
            setStateImage(with: imageName)
        } else {
            removeImageForAllStates()
        }
        
        if let title = title, !title.isEmpty, imageName != nil {
            setImageAlign(to: imageAlign)
        }
    }
    
}
