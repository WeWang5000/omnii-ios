//
//  UIButton+Omnii.swift
//  omnii
//
//  Created by huyang on 2023/5/16.
//

import UIKit
import CommonUtils
import Kingfisher
import SwifterSwift
import DynamicBlurView

extension UIButton {
    
    func whiteBackgroundStyle(title: String) {
        setRoundBackgroundColor(.white, size: size, for: .normal)
        setRoundBackgroundColor(.white.withAlphaComponent(0.7), for: .highlighted)
        setRoundBackgroundColor(.white.withAlphaComponent(0.2), for: .disabled)
        setTitleForAllStates(title)
        setTitleColor(.black, for: .normal)
        setTitleColor(.black, for: .highlighted)
        setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
        titleLabel?.font = UIFont(type: .montserratBlod, size: 18.rpx)
    }
    
    func setRoundBackgroundColor(_ color: UIColor?, size: CGSize = .zero, for state: UIControl.State) {
        guard let color = color else { return }
        let imageSize = (size == .zero) ? self.size : size
        let bgImage = UIImage(color: color, size: imageSize, scale: UIScreen.main.scale)
        setBackgroundImage(bgImage, for: state)
        cornerRadius = imageSize.height / 2.0
    }
    
    func setNormalAvatar(title: String) {
        setTitle(title, for: .normal)
        setRoundBackgroundColor(.purple, for: .normal)
        setRoundBackgroundColor(.purple.withAlphaComponent(0.6), for: .highlighted)
    }
    
}
