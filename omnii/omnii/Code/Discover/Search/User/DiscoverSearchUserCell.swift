//
//  DiscoverSearchUserCell.swift
//  omnii
//
//  Created by huyang on 2023/6/17.
//

import UIKit
import Kingfisher
import CommonUtils

final class DiscoverSearchUserCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            titleLabel.alpha = isHighlighted ? 0.7 : 1.0
            subTitleLabel.alpha = isHighlighted ? 0.7 : 1.0
        }
    }
    
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var subTitleLabel: UILabel!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: DiscoverSearchSingleUserViewModel) {
        
        let url = URL(string: viewModel.model.userAvatar)
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "avatar_default_normal"),
                              options: [.transition(.fade(0.5))])
        titleLabel.text = viewModel.model.userNickName
        subTitleLabel.text = viewModel.model.userId
        
    }
    
    // MARK: - private
    
    private func setupViews() {
        
        imageView = UIImageView().then {
            $0.cornerRadius = 25.rpx
            $0.contentMode = .scaleAspectFill
            let size = CGSize(width: 50.rpx, height: 50.rpx)
            let x = 20.rpx
            let y = (DiscoverSearchUserController.cellHeight - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }
                
        titleLabel = UILabel().then {
            $0.textColor = .white
            $0.textAlignment = .left
            $0.font = UIFont(type: .montserratMedium, size: 18.rpx)
            let x = imageView.frame.maxX + 15.rpx
            let width = ScreenWidth - x - 15.rpx
            let height = String.singleLineHeight(font: $0.font)
            let y = imageView.y + 6.rpx
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        subTitleLabel = UILabel().then {
            $0.textColor = .white.withAlphaComponent(0.4)
            $0.textAlignment = .left
            $0.font = UIFont(type: .montserratLight, size: 13.rpx)
            let width = titleLabel.width
            let height = String.singleLineHeight(font: $0.font)
            let x = titleLabel.x
            let y = imageView.frame.maxY - height - 6.rpx
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        addSubviews([imageView, titleLabel, subTitleLabel])
    }
    
}
