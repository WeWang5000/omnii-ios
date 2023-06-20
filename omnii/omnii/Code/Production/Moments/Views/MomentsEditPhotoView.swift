//
//  MomentsEditView.swift
//  omnii
//
//  Created by huyang on 2023/5/16.
//

import UIKit
import CommonUtils
import SwiftRichString

class MomentsEditPhotoView: UIView {
    
    enum State {
        case back
        case word
        case next
        case location
    }
    
    var actionEvent: ((State) -> Void)?
    
    var isBackHidden: Bool {
        didSet {
            closeButton.isHidden = isBackHidden
        }
    }
    
    private var imageView: UIImageView!
    private var wordButton: UIButton!
    private var nextButton: UIButton!
    private var closeButton: UIButton!
    private var locationButton: UIButton!
    private var textButton: UIButton!       // 说说
    
    private var text: String = ""
    
    private var isZoomOut: Bool = false   // 缩小
    
    init(frame: CGRect = UIScreen.main.bounds, image: UIImage?) {
        self.isBackHidden = false
        super.init(frame: frame)
        
        backgroundColor = .black
        setupViews()
        updateImage(image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func updateWord(_ text: String) {
        wordButton.isHidden = (text.count > 0)
        textButton.isHidden = !(text.count > 0)
        updateText(text)
    }
    
    func updateLocation(with name: String) {
        layoutLocation(with: name)
    }
    
}

private extension MomentsEditPhotoView {
    
    func setupViews() {
        
        imageView = UIImageView().then {
            $0.cornerRadius = 20.rpx
            $0.contentMode = .scaleAspectFill
            let x = 0.0
            let y = ScreenFit.statusBarHeight
            let width = ScreenWidth
            let height = ScreenHeight - ScreenFit.statusBarHeight - 66.rpx - ScreenFit.safeBottomHeight
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
            $0.backgroundColor = .black
            $0.isUserInteractionEnabled = true
        }
        
        closeButton = UIButton(imageName: "camera_back").then {
            let size = CGSize(width: 40.rpx, height: 40.rpx)
            let origin = CGPoint(x: 20.rpx, y: 20.rpx)
            $0.frame = CGRect(origin: origin, size: size)
            let bgColor = UIColor.black.withAlphaComponent(0.4)
            $0.setRoundBackgroundColor(bgColor, for: .normal)
        }
        
        wordButton = UIButton(type: .custom).then {
            let size = CGSize(width: 45.rpx, height: 45.rpx)
            let x = closeButton.x
            let y = imageView.height - 25.rpx - size.height
            $0.frame = CGRect(x: x, y: y, size: size)
            let bgColor = UIColor.black.withAlphaComponent(0.4)
            $0.setRoundBackgroundColor(bgColor, for: .normal)
            $0.setTitleForAllStates("Aa")
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
            $0.titleLabel?.numberOfLines = 0
        }
        
        locationButton = UIButton(imageName: "camer_location").then {
            let size = wordButton.size
            let x = self.width - 20.rpx - size.width
            let y = wordButton.y
            $0.frame = CGRect(x: x, y: y, size: size)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
            let bgColor = UIColor.black.withAlphaComponent(0.4)
            $0.setRoundBackgroundColor(bgColor, for: .normal)
        }
        
        nextButton = UIButton(type: .custom).then {
            let size = CGSize(width: 320.rpx, height: 55.rpx)
            let x = (self.width - size.width) / 2.0
            let y = imageView.frame.maxY + 10.rpx
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            $0.setRoundBackgroundColor(.white, for: .normal)
            $0.setTitleForAllStates("Next")
            $0.setTitleColorForAllStates(.black)
            $0.titleLabel?.font = UIFont(type: .montserratBlod, size: 18.rpx)
        }
        
        textButton = UIButton(type: .custom).then {
            let width = self.width * 0.5
            let height = 20.rpx
            let x = 15.0
            let y = imageView.height - 21.0 - height
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
            $0.isHidden = true
            $0.titleLabel?.numberOfLines = 0
        }
        
        wordButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        textButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        addSubview(imageView)
        addSubview(nextButton)

        imageView.addSubview(closeButton)
        imageView.addSubview(wordButton)
        imageView.addSubview(locationButton)
        imageView.addSubview(textButton)
        
    }
    
    func layoutLocation(with name: String) {
        let font = UIFont(type: .montserratMedium, size: 15.rpx)!
        let width = min(name.width(font: font), 70.rpx)
        locationButton.do {
            let size = CGSize(width: width + 60.rpx, height: 55.rpx)
            let x = self.width - 20.rpx - size.width
            let y = wordButton.y
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
    
    func updateText(_ text: String, fontSize: Double = 14.rpx) {
        self.text = text
        let style = Style {
            $0.alignment = .left
            $0.color = UIColor.white
            $0.font = UIFont(type: .montserratRegular, size: fontSize)!
            $0.lineHeightMultiple = 1.06
        }
        let attStr = text.set(style: style)
        textButton.setAttributedTitle(attStr, for: .normal)

        style.color = UIColor.white.withAlphaComponent(0.7)
        let attStrHighlight = text.set(style: style)
        textButton.setAttributedTitle(attStrHighlight, for: .highlighted)
        
        textButton.titleLabel?.numberOfLines = 0

        let width = imageView.width * 0.5
        let size = attStr.size(containerWidth: width)
        let x = textButton.x
        let y = imageView.height - 21.rpx - size.height
        textButton.frame = CGRect(x: x, y: y, size: size)
    }
    
    @objc func click(_ sender: UIButton) {
        guard let action = actionEvent else { return }
        if sender == closeButton {
            action(.back)
        } else if sender == wordButton {
            action(.word)
        } else if sender == locationButton {
            action(.location)
        } else if sender == nextButton {
            action(.next)
        } else if sender == textButton {
            action(.word)
        }
    }
    
}

// MARK: - animation

extension MomentsEditPhotoView {
    
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
        let width = ScreenWidth * scale
        let height = (ScreenHeight - ScreenFit.statusBarHeight - 66.rpx - ScreenFit.safeBottomHeight) * scale
        let x = (ScreenWidth - width) / 2.0
        let y = ScreenFit.statusBarHeight
        imageView.frame = CGRect(x: x, y: y, width: width, height: height)
        imageView.cornerRadius = 20.rpx * scale
        
        updateText(text, fontSize: 14.rpx * scale)
    }
    
    func makeHidden(_ hidden: Bool) {
        nextButton.isHidden = hidden
        closeButton.isHidden = hidden
        locationButton.isHidden = hidden
        wordButton.isHidden = hidden ? true : (text.count > 0)
    }
    
}
