//
//  PickerHeaderView.swift
//  omnii
//
//  Created by huyang on 2023/5/17.
//

import UIKit
import CommonUtils

class PickerHeaderView: UIView {

    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    private(set) var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        let topSlider = UIView().then {
            $0.backgroundColor = .white.withAlphaComponent(0.2)
            let size = CGSize(width: 35.rpx, height: 4.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = 16.rpx
            $0.frame = CGRect(x: x, y: y, size: size)
            $0.cornerRadius = size.height / 2.0
        }
        
        titleLabel = UILabel().then {
            $0.textColor = .white
            $0.font = UIFont(type: .montserratSemiBlod, size: 20.rpx)
            $0.textAlignment = .center
            let x = 20.0
            let y = topSlider.frame.maxY + 15.rpx
            let width = ScreenWidth - x * 2
            let height = 22.rpx
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        addSubview(topSlider)
        addSubview(titleLabel)
    }
    
}
