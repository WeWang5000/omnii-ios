//
//  ShareFriendsAllCell.swift
//  omnii
//
//  Created by huyang on 2023/5/30.
//

import UIKit
import Combine
import CommonUtils

final class AllFriendsPickCell: UICollectionViewCell {
    
    static let cellHeight = 65.rpx
        
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var isPicked: Bool {
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
            $0.contentMode = .scaleToFill
            let size = CGSize(width: 50.rpx, height: 50.rpx)
            let x = 20.rpx
            let y = (AllFriendsPickCell.cellHeight - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        switchButton = UIButton(imageName: "moments_check").then {
            $0.isUserInteractionEnabled = false
            let size = CGSize(width: 22.rpx, height: 22.rpx)
            let x = ScreenWidth - 20.rpx - size.width
            let y = (AllFriendsPickCell.cellHeight - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }
                
        titleLabel = UILabel().then {
            $0.textColor = .white
            $0.textAlignment = .left
            $0.font = UIFont(type: .montserratMedium, size: 18.rpx)
            let x = imageView.frame.maxX + 15.rpx
            let width = switchButton.x - x - 15.rpx
            let height = String.singleLineHeight(font: $0.font)
            let y = (AllFriendsPickCell.cellHeight - height) / 2.0
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        addSubviews([imageView, switchButton, titleLabel])
    }
    
}


extension AllFriendsPickCell {
    
    func bindViewModel(_ viewModel: AllFriendsCellModel) {
        image = UIImage(named: "avatar_default_normal")
        title = viewModel.model.name
        switchButton.isSelected = viewModel.model.isSelected
        
        viewModel.selectedPublisher
            .assign(to: \.isPicked, on: self, ownership: .weak)
            .store(in: &cancellables)
    }
    
}
