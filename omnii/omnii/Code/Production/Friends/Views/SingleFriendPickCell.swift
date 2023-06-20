//
//  ShareFriendsCell.swift
//  omnii
//
//  Created by huyang on 2023/5/30.
//

import UIKit
import Combine
import Kingfisher
import CommonUtils

final class SingleFriendPickCell: UICollectionViewCell {
    
    static let cellHeight = 65.rpx
    
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var subTitle: String? {
        get { subTitleLabel.text }
        set { subTitleLabel.text = newValue }
    }
    
    private var isPicked: Bool {
        get { switchButton.isSelected }
        set { switchButton.isSelected = newValue }
    }
    
    override var isHighlighted: Bool {
        didSet {
            switchButton.isHighlighted = isHighlighted
            titleLabel.alpha = isHighlighted ? 0.7 : 1.0
        }
    }
    
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var subTitleLabel: UILabel!
    private var switchButton: UIButton!
        
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - private
    
    private func setupViews() {
        
        imageView = UIImageView().then {
            $0.cornerRadius = 25.rpx
            $0.contentMode = .scaleAspectFill
            let size = CGSize(width: 50.rpx, height: 50.rpx)
            let x = 20.rpx
            let y = (SingleFriendPickCell.cellHeight - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        switchButton = UIButton(imageName: "moments_check").then {
            $0.isUserInteractionEnabled = false
            let size = CGSize(width: 22.rpx, height: 22.rpx)
            let x = ScreenWidth - 20.rpx - size.width
            let y = (SingleFriendPickCell.cellHeight - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }
                
        titleLabel = UILabel().then {
            $0.textColor = .white
            $0.textAlignment = .left
            $0.font = UIFont(type: .montserratMedium, size: 18.rpx)
            let x = imageView.frame.maxX + 15.rpx
            let width = switchButton.x - x - 15.rpx
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
        
        addSubviews([imageView, switchButton, titleLabel, subTitleLabel])
    }
    
}

extension SingleFriendPickCell {
    
    func bindViewModel(_ viewModel: SingleFriendCellModel) {
        let url = URL(string: viewModel.model.userAvatar)
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "avatar_default_normal"),
                              options: [.transition(.fade(0.5))])
        title = viewModel.model.userNickName
        subTitle = viewModel.model.userOmniiNo
        switchButton.isSelected = viewModel.isSelected
        
        viewModel.selectedPublisher
            .assign(to: \.isPicked, on: self, ownership: .weak)
            .store(in: &cancellables)
    }
    
}
