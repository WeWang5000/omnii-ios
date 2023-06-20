//
//  MomentsEditMindView.swift
//  omnii
//
//  Created by huyang on 2023/5/21.
//

import UIKit
import CommonUtils
import SwiftRichString

class MomentsEditMindView: UIView {
    
    enum State {
        case back
        case next
        case location
    }
    
    var actionEvent: ((State) -> Void)?
    
    var isBackHidden: Bool {
        didSet {
            closeButton.isHidden = isBackHidden
        }
    }
    
    private var mindLabel: UILabel!
    private var nextButton: UIButton!
    private var closeButton: UIButton!
    private var locationButton: UIButton!
    
    private var mind: String
    
    private var isZoomOut: Bool = false   // 缩小

    required init(frame: CGRect = UIScreen.main.bounds, mind: String) {
        self.mind = mind
        self.isBackHidden = false
        super.init(frame: frame)
        
        backgroundColor = .black
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLocation(with name: String) {
        layoutLocation(with: name)
    }
    
}

private extension MomentsEditMindView {
    
    func setupViews() {
        
        mindLabel = UILabel().then {
            $0.cornerRadius = 20.rpx
            $0.isUserInteractionEnabled = true
            $0.textColor = .white
            $0.font = UIFont(type: .montserratMedium, size: 32.rpx)
            $0.text = mind
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            let x = 0.0
            let y = ScreenFit.statusBarHeight
            let width = ScreenWidth
            let height = ScreenHeight - ScreenFit.statusBarHeight - 66.rpx - ScreenFit.safeBottomHeight
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
            let start = UIColor.white.withAlphaComponent(0.1)
            let end = UIColor.white.withAlphaComponent(0.2)
            $0.backgroundColor = UIColor(gradientColors: [start, end], bounds: $0.bounds, direction: .vertical)
        }
        
        closeButton = UIButton(imageName: "camera_back").then {
            let size = CGSize(width: 40.rpx, height: 40.rpx)
            let x = 20.rpx
            let y = mindLabel.y + 20.rpx
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            let bgColor = UIColor.black.withAlphaComponent(0.4)
            $0.setRoundBackgroundColor(bgColor, for: .normal)
        }
        
        locationButton = UIButton(imageName: "camer_location").then {
            let size = CGSize(width: 45.rpx, height: 45.rpx)
            let x = self.width - 20.rpx - size.width
            let y = mindLabel.frame.maxY - 25.rpx - size.height
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
            let bgColor = UIColor.black.withAlphaComponent(0.4)
            $0.setRoundBackgroundColor(bgColor, for: .normal)
        }
        
        nextButton = UIButton(type: .custom).then {
            let size = CGSize(width: 320.rpx, height: 55.rpx)
            let x = (self.width - size.width) / 2.0
            let y = mindLabel.frame.maxY + 10.rpx
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            $0.setRoundBackgroundColor(.white, for: .normal)
            $0.setTitleForAllStates("Next")
            $0.setTitleColorForAllStates(.black)
            $0.titleLabel?.font = UIFont(type: .montserratBlod, size: 18.rpx)
        }
        
        nextButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        addSubview(mindLabel)
        addSubview(closeButton)
        addSubview(locationButton)
        addSubview(nextButton)
        
    }
    
    func layoutLocation(with name: String) {
        let font = UIFont(type: .montserratMedium, size: 15.rpx)!
        let width = min(name.width(font: font), 70.rpx)
        locationButton.do {
            let size = CGSize(width: width + 60.rpx, height: 55.rpx)
            let x = self.width - 20.rpx - size.width
            let y = mindLabel.frame.maxY - 25.rpx - size.height
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            $0.setTitleForAllStates(name)
            $0.titleLabel?.lineBreakMode = .byTruncatingTail
            $0.setImageAlign(to: .left(2.5))
            $0.titleEdgeInsets = UIEdgeInsets(top: .zero, left: 16.rpx, bottom: .zero, right: 16.rpx)
            $0.titleLabel?.font = font
            let bgColor = UIColor.black.withAlphaComponent(0.4)
            $0.setRoundBackgroundColor(bgColor, for: .normal)
        }
    }
    
    @objc func click(_ sender: UIButton) {
        guard let action = actionEvent else { return }
        if sender == closeButton {
            action(.back)
        } else if sender == locationButton {
            action(.location)
        } else if sender == nextButton {
            action(.next)
        }
    }
    
}

// MARK: - animation

extension MomentsEditMindView {
    
    func toZoomOut() {
        makeHidden(true)
        
        let scale = 0.6
        makeZoom(scale: scale)
    }
    
    func toZoomIn(progress: Double = 1.0) {
        let scale = progress * 0.4 + 0.6
        makeZoom(scale: scale)
    }
    
    private func makeZoom(scale: Double) {
        mindLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    func makeHidden(_ hidden: Bool) {
        nextButton.isHidden = hidden
        closeButton.isHidden = hidden
        locationButton.isHidden = hidden
    }
    
}

