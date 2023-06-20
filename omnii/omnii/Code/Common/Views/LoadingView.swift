//
//  LoadingView.swift
//  omnii
//
//  Created by huyang on 2023/6/15.
//

import UIKit
import CommonUtils

final class LoadingView: UIView {
    
    private var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        start()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        imageView.isHidden = false
        imageView.layer.add(animation, forKey: "animation")
    }
    
    func end() {
        imageView.layer.removeAllAnimations()
        imageView.isHidden = true
    }
    
    private func setupViews() {
        
        imageView = UIImageView().then {
            $0.image = UIImage(named: "discover_loading")
            $0.contentMode = .center
            let size = CGSize(width: 38.rpx, height: 38.rpx)
            let x = (self.width - size.width) / 2.0
            let y = (self.height - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        addSubview(imageView)
    }
    
    private lazy var animation: CAAnimation = {
        let duration: CFTimeInterval = 0.75

        //    Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")

        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.values = [1, 0.6, 1]

        // Rotate animation
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")

        rotateAnimation.keyTimes = scaleAnimation.keyTimes
        rotateAnimation.values = [0, Double.pi, 2 * Double.pi]

        // Animation
        let animation = CAAnimationGroup()

        animation.animations = [scaleAnimation, rotateAnimation]
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        return animation
    }()

}
