//
//  MomentsLocationCell.swift
//  omnii
//
//  Created by huyang on 2023/5/17.
//

import UIKit
import CommonUtils

final class MomentsLocationCell: UICollectionViewCell {
    
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            imageView.alpha = isHighlighted ? 0.7 : 1.0
            titleLabel.textColor = isHighlighted ? .white.withAlphaComponent(0.7) : .white
        }
    }
    
}

private extension MomentsLocationCell {
    
    func setupViews() {
        
        imageView = UIImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(named: "moments_location_normal")
            let size = CGSize(width: 28.rpx, height: 28.rpx)
            let x = 32.0
            let y = (52.rpx - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        titleLabel = UILabel().then {
            $0.textColor = .white
            $0.font = UIFont(type: .montserratRegular, size: 15.rpx)
            $0.textAlignment = .left
            $0.numberOfLines = 1
            $0.lineBreakMode = .byTruncatingTail
            let x = imageView.frame.maxX + 12.0
            let width = ScreenWidth - x - 16.0
            let height = 18.rpx
            let y = (52.rpx - height) / 2.0
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        addSubview(imageView)
        addSubview(titleLabel)
    }
    
}
