//
//  InvitesBorderButton.swift
//  omnii
//
//  Created by huyang on 2023/5/25.
//

import UIKit

final class InvitesBorderButton: UIControl {

    override var isHighlighted: Bool {
        didSet {
            imageView.alpha = isHighlighted ? 0.7 : 1.0
            titleLabel.alpha = isHighlighted ? 0.7 : 1.0
            contentLabel.alpha = isHighlighted ? 0.7 : 1.0
        }
    }
    
    var title: String? {
        get { titleLabel.text }
        set {
            if titleLabel.text != newValue {
                titleLabel.text = newValue
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    
    var titleFont: UIFont? {
        get { titleLabel.font }
        set { titleLabel.font = newValue }
    }
    
    var content: String? {
        get { contentLabel.text }
        set {
            if contentLabel.text != newValue {
                contentLabel.text = newValue
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    
    var contentFont: UIFont? {
        get { contentLabel.font }
        set { contentLabel.font = newValue }
    }
    
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    var scale: Double {
        get { _scale }
        set {
            _scale = newValue
            cornerRadius = 10.rpx * newValue
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private var _scale: Double = 1.0
    
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var contentLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cornerRadius = 10.rpx
        borderColor = .white.withAlphaComponent(0.1)
        borderWidth = 1.0
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.do {
            let size = CGSize(width: 28.rpx * scale, height: 28.rpx * scale)
            let x = 10.rpx * scale
            let y = (self.height - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        titleLabel.do {
            $0.font = UIFont(type: .montserratBlod, size: 14.rpx * scale)
            let x = imageView.frame.maxX + 5.rpx
            let y = 8.rpx * scale
            let width = self.width - x - 10.rpx * scale
            let height = 15.rpx * scale
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        contentLabel.do {
            $0.font = UIFont(type: .montserratRegular, size: 12.rpx * scale)
            let height = 15.rpx * scale
            let x = imageView.frame.maxX + 5.rpx
            let y = self.height - height - 8.rpx * scale
            let width = self.width - x - 10.rpx * scale
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
    }
    
    private func setupViews() {
        
        imageView = UIImageView().then {
            $0.contentMode = .center
        }
        
        titleLabel = UILabel().then {
            $0.textColor = .white
            $0.font = UIFont(type: .montserratBlod, size: 14.rpx)
        }
        
        contentLabel = UILabel().then {
            $0.textColor = .white.withAlphaComponent(0.7)
            $0.font = UIFont(type: .montserratRegular, size: 12.rpx)
            $0.lineBreakMode = .byTruncatingTail
        }
        
        addSubviews([imageView, titleLabel, contentLabel])
    }

}
