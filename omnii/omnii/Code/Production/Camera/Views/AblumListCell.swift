//
//  AblumListCell.swift
//  omnii
//
//  Created by huyang on 2023/5/10.
//

import UIKit
import CommonUtils

class AblumListCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            self.hignlightView.backgroundColor = isHighlighted ? highlightedColor : normalColor
        }
    }
    
    private let normalColor = UIColor(hexString: "#151517")
    private let highlightedColor = UIColor.white.withAlphaComponent(0.1)
    
    private var imageView: UIImageView!
    private var nameLabel: UILabel!
    private var countLabel: UILabel!
    private var hignlightView: UIView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = normalColor
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindModel(_ model: PhotoCollectionModel) {
        nameLabel.text = model.name
        countLabel.text = "\(model.count)"
        model.loadThumbnail { [unowned self] image in
            if let image = image {
                self.imageView.image = image.cropped(scale: 1)
            }
        }
    }
    
}


private extension AblumListCell {
    
    private func setupViews() {
        
        hignlightView = UIView().then {
            let x = 0.0
            let y = 0.0
            let width = ScreenWidth
            let height = 60.rpx
            $0.frame = CGRectMake(x, y, width, height)
            $0.backgroundColor = normalColor
        }
        
        imageView = UIImageView().then {
            let size = CGSize(width: 60.rpx, height: 60.rpx)
            let x = 20.0
            let y = 0.0
            $0.frame = CGRectMake(x, y, size.width, size.height)
            $0.cornerRadius = 4.rpx
            $0.contentMode = .scaleAspectFit
        }
        
        nameLabel = UILabel().then {
            let width = 100.rpx
            let height = 38.rpx
            let x = imageView.frame.maxX + 16.rpx
            let y = (imageView.height - height) / 2.0
            $0.frame = CGRectMake(x, y, width, height)
            $0.font = UIFont(type: .montserratRegular, size: 16.rpx)
            $0.lineBreakMode = .byTruncatingTail
            $0.textColor = .white
        }
        
        countLabel = UILabel().then {
            let width = 80.rpx
            let height = 38.rpx
            let x = nameLabel.frame.maxX + 7.5
            let y = nameLabel.y
            $0.frame = CGRectMake(x, y, width, height)
            $0.font = UIFont(type: .montserratLight, size: 16.rpx)
            $0.textColor = UIColor(hexString: "#AAAAAA")
            $0.textAlignment = .left
            $0.adjustsFontSizeToFitWidth = true
        }
        
        addSubviews([hignlightView, imageView, nameLabel, countLabel])
        
    }
    
    private func updateNameLayout(width: Double) {
        
        nameLabel.do {
            let width = width
            let height = 38.rpx
            let x = imageView.frame.maxX + 16.rpx
            let y = (imageView.height - height) / 2.0
            $0.frame = CGRectMake(x, y, width, height)
        }
        
        updateCountLayout(width: countLabel.width)
    }
    
    private func updateCountLayout(width: Double) {
        countLabel.do {
            let width = width
            let height = 38.rpx
            let x = nameLabel.frame.maxX + 7.5
            let y = nameLabel.y
            $0.frame = CGRectMake(x, y, width, height)
        }
    }
    
    private func setName(_ text: String) {
        nameLabel.text = text
        let attrs: [NSAttributedString.Key : Any] = [.font: nameLabel.font!]
        let width = text.width(attributes: attrs, containerHeight: nameLabel.height)
        updateNameLayout(width: width)
    }
    
}
