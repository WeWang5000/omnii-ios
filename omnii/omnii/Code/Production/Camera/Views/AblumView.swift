//
//  AblumView.swift
//  omnii
//
//  Created by huyang on 2023/5/9.
//

import UIKit
import CommonUtils

class AblumView: UIView {
    
    enum AblumActionType {
        case close
        case openAblumList
    }
    
    var ablumAction: ((AblumActionType) -> Void)?
    
    private(set) var collectionView: UICollectionView!
    private var closeButton: UIButton!
    private var titleButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTitle(title: String) {
        titleButton.setTitleForAllStates(title)
        titleButton.setImageAlign(to: .right(2.0))
    }
    
}

private extension AblumView {
    
    func setupViews() {
        
        closeButton = UIButton(imageName: "camera_close").then({ btn in
            let size = CGSize(width: 40.rpx, height: 40.rpx)
            let x = 20.0
            let y = 21.0 + ScreenFit.statusBarHeight
            btn.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            let bgColor = UIColor.white.withAlphaComponent(0.1)
            let bgImage = UIImage(color: bgColor, size: size).withRoundedCorners()
            if let image = bgImage {
                btn.setBackgroundImage(image, for: .normal)
            }
        })
        
        titleButton = UIButton(imageName: "ablum_up").then({ btn in
            btn.titleLabel?.font = UIFont(type: .montserratSemiBlod, size: 20.rpx)
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            btn.setTitleForAllStates("Recents")
            btn.setImageAlign(to: .right(2.0))
            let width = self.width / 2.0
            let height = 40.rpx
            let x = (self.width - width) / 2.0
            let y = closeButton.y
            btn.frame = CGRect(x: x, y: y, width: width, height: height)
        })
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then({ view in
            view.backgroundColor = .black
            let x = 0.0
            let y = 76.0 + ScreenFit.statusBarHeight
            let width = self.width
            let height = self.height - y
            view.frame = CGRect(x: x, y: y, width: width, height: height)
        })
        
        closeButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        titleButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        addSubview(closeButton)
        addSubview(titleButton)
        addSubview(collectionView)
    }
    
    @objc private func click(_ sender: UIButton) {
        guard let action = ablumAction else { return }
        if sender == closeButton {
            action(.close)
        } else if sender == titleButton {
            action(.openAblumList)
        }
    }
    
}
