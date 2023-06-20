//
//  MomentsLocationHeader.swift
//  omnii
//
//  Created by huyang on 2023/5/16.
//

import UIKit
import CommonUtils

final class MomentsLocationHeader: UICollectionReusableView {
    
    var name: String? {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }

    private var nameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        nameLabel = UILabel().then {
            $0.textColor = .white.withAlphaComponent(0.4)
            $0.font = UIFont(type: .montserratRegular, size: 15.rpx)
            $0.textAlignment = .left
            let x = 35.0
            let width = ScreenWidth - x * 2
            let height = 19.rpx
            let y = 36.rpx - height - 5.0
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        addSubview(nameLabel)
    }

}
