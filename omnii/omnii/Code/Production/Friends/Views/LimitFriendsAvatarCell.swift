//
//  ShareFriendsLimitCell.swift
//  omnii
//
//  Created by huyang on 2023/5/30.
//

import UIKit
import Combine
import CommonUtils
import Kingfisher

final class LimitFriendsAvatarCell: UICollectionViewCell {
    
    static let cellHeight = 90.rpx
    private let showLimit = 6      // 可展示头像数量
    
    private var titleLabel: UILabel!
    private var imageViews = [AvatarView]()
    
    private var cancellable: AnyCancellable?
    
    deinit {
//        cancellables.forEach { $0.cancel() }
        cancellable?.cancel()
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
        cancellable?.cancel()
    }
    
    // MARK: - private
    
    private func setupViews() {
        
        titleLabel = UILabel().then {
            let title = "Limit of 12"
            $0.text = title
            $0.textColor = .white.withAlphaComponent(0.4)
            $0.textAlignment = .left
            let font = UIFont(type: .montserratRegular, size: 15.rpx)
            $0.font = font
            let size = title.size(font: font!)
            let x = 25.rpx
            let y = (LimitFriendsAvatarCell.cellHeight - size.height - 50.rpx - 10.rpx) / 2.0
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        }
        
        for i in 0..<showLimit {
            
            let imageView = AvatarView().then {
                $0.isHidden = true
                let x = 20.rpx + Double(i) * 35.rpx
                let y = self.titleLabel.frame.maxY + 10.rpx
                let size = CGSize(width: 50.rpx, height: 50.rpx)
                $0.frame = CGRect(x: x, y: y, size: size)
            }
            
            imageViews.append(imageView)
        }
        
        addSubview(titleLabel)
        addSubviews(imageViews)
    }
    
    private func updateFriends(_ friends: [FriendModel]?) {
        updateImageViews(with: friends)
    }
    
    private func updateImageViews(with friends: [FriendModel]?) {
        
        guard let friends = friends else {
            for imageView in imageViews {
                imageView.isHidden = true
            }
            return
        }

        let placeholder = UIImage(named: "avatar_default_normal")
        
        for (i, imageView) in imageViews.enumerated() {
            
            if friends.count > i {
               
                imageView.isHidden = false
                imageView.isBorderHidden = i < 1
                imageView.showCoverView(i == showLimit - 1, text: "+\(friends.count - i)")
                
                let url = URL(string: friends[i].userAvatar)
                KF.url(url)
                    .placeholder(placeholder)
                    .fade(duration: 0.35)
                    .cacheMemoryOnly()
                    .set(to: imageView)
                
            } else {
            
                imageView.isHidden = true
                
            }
            
        }
        
    }
    
}

extension LimitFriendsAvatarCell {
    
    func bindViewModel(_ viewModel: LimitFriendsCellModel) {
        
        cancellable = viewModel.updateFriendsPublisher
            .sink { [unowned self] friends in
                self.updateFriends(friends)
            }
        
    }
    
}


private class AvatarView: UIImageView {
    
    var isBorderHidden: Bool {
        get { borderWidth == .zero }
        set { showBorder(!newValue) }
    }
    
    private var coverLabel: UILabel!
    
    init() {
        super.init(frame: .zero)
        cornerRadius = 25.rpx
        borderColor = .white.withAlphaComponent(0.9)
        addCoverView(with: "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showCoverView(_ show: Bool, text: String) {
        coverLabel.isHidden = !show
        coverLabel.text = text
    }
    
    func addCoverView(with text: String) {
        
        coverLabel = UILabel().then {
            $0.isHidden = true
            $0.text = text
            $0.textColor = .white
            $0.textAlignment = .center
            $0.font = UIFont(type: .montserratBlod, size: 20.rpx)
            $0.backgroundColor = .black.withAlphaComponent(0.8)
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 50.rpx, height: 50.rpx))
        }
        
        addSubview(coverLabel!)
    }
    
    private func showBorder(_ show: Bool) {
        if show {
            borderWidth = 1.5
        } else {
            borderWidth = .zero
        }
    }
    
}
