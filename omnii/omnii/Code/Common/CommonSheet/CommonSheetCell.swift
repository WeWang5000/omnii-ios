//
//  CommonSheetCell.swift
//  omnii
//
//  Created by huyang on 2023/6/16.
//

import UIKit
import CommonUtils

final class CommonSheetCell: UICollectionViewCell {
    
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
    
    func bindItem(_ item: CommonSheetItem) {
        imageView.image = item.icon
        titleLabel.text = item.title
    }
    
    private func setupViews() {
        
        imageView = UIImageView().then {
            $0.contentMode = .scaleAspectFit
            let size = CGSize(width: 28.rpx, height: 28.rpx)
            let x = 20.rpx
            let y = (52.rpx - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        titleLabel = UILabel().then {
            $0.textColor = .white
            $0.font = UIFont(type: .montserratRegular, size: 13.rpx)
            $0.textAlignment = .left
            $0.numberOfLines = 1
            $0.lineBreakMode = .byTruncatingTail
            let x = imageView.frame.maxX + 7.rpx
            let width = ScreenWidth - x - 20.rpx
            let height = 20.rpx
            let y = (52.rpx - height) / 2.0
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        addSubview(imageView)
        addSubview(titleLabel)
    }
    
}
