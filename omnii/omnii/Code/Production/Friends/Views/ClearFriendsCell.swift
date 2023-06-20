//
//  ShareFriendsClearCell.swift
//  omnii
//
//  Created by huyang on 2023/5/30.
//

import UIKit
import CommonUtils

final class ClearFriendsCell: UICollectionViewCell {
    
    static let cellHeight = 33.rpx
    
    var clearHandler: (() -> Void)?
    
    private var titleLabel: UILabel!
    private var clearButton: UIButton!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - private
    
    private func setupViews() {
        
        titleLabel = UILabel().then {
            let title = "Select Friends"
            $0.text = title
            $0.textColor = .white.withAlphaComponent(0.4)
            $0.textAlignment = .left
            let font = UIFont(type: .montserratRegular, size: 15.rpx)
            $0.font = font
            let attrs: [NSAttributedString.Key : Any] = [.font: font!]
            let size = title.size(attributes: attrs)
            let x = 25.rpx
            let y = ClearFriendsCell.cellHeight - size.height - 3.rpx
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        }
        
        clearButton = UIButton(type: .custom).then {
            let title = "Clear all"
            $0.setTitleForAllStates(title)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
            let font = UIFont(type: .montserratRegular, size: 15.rpx)
            $0.titleLabel?.font = font
            let attrs: [NSAttributedString.Key : Any] = [.font: font!]
            let size = title.size(attributes: attrs)
            let x = ScreenWidth - 26.rpx - size.width
            let y = titleLabel.y
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        }
        
        clearButton.addTarget(self, action: #selector(click), for: .touchUpInside)
        
        addSubviews([titleLabel, clearButton])
    }
    
    @objc private func click(_ sender: UIButton) {
        clearHandler?()
    }
    
}
