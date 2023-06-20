//
//  InvitesLocationCell.swift
//  omnii
//
//  Created by huyang on 2023/5/27.
//

import UIKit
import CommonUtils

class InvitesLocationCell: UICollectionViewCell {
    
    var title: String?{
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var detail: String? {
        get { detailLabel.text }
        set { detailLabel.text = newValue }
    }
    
    var distance: String? {
        get { distanceLabel.text }
        set { distanceLabel.text = newValue }
    }
    
    private var titleLabel: UILabel!
    private var detailLabel: UILabel!
    private var distanceLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            titleLabel.alpha = isHighlighted ? 0.7 : 1.0
            detailLabel.alpha = isHighlighted ? 0.7 : 1.0
            distanceLabel.alpha = isHighlighted ? 0.7 : 1.0
        }
    }

    func setLayout(_ layout: LocationLayout) {
        
        titleLabel.frame = CGRect(x: 20.rpx,
                                  y: layout.topPadding,
                                  size: layout.titleSize)
        
        detailLabel.frame = CGRect(x: 20.rpx,
                                   y: titleLabel.frame.maxY + layout.middlePadding,
                                   size: layout.detailSize)
        
        distanceLabel.frame = CGRect(x: ScreenWidth - layout.distanceSize.width - 20.rpx,
                                     y: detailLabel.frame.maxY - layout.distanceSize.height,
                                     size: layout.distanceSize)
        
    }
    
}

private extension InvitesLocationCell {
    
    func setupViews() {
        
        titleLabel = UILabel().then {
            $0.numberOfLines = 0
            $0.textColor = .white
            $0.textAlignment = .left
            $0.font = UIFont(type: .montserratBlod, size: 14.rpx)
        }
        
        detailLabel = UILabel().then {
            $0.numberOfLines = 0
            $0.textColor = .white.withAlphaComponent(0.5)
            $0.textAlignment = .left
            $0.font = UIFont(type: .montserratRegular, size: 12.rpx)
        }
        
        distanceLabel = UILabel().then {
            $0.textColor = .white.withAlphaComponent(0.5)
            $0.textAlignment = .right
            $0.font = UIFont(type: .montserratRegular, size: 12.rpx)
        }
        
        addSubviews([titleLabel, detailLabel, distanceLabel])
        
    }
    
}
