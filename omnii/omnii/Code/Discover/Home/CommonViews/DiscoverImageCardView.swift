//
//  DiscoverImageCardView.swift
//  omnii
//
//  Created by huyang on 2023/6/3.
//

import UIKit
import Kingfisher
import SwifterSwift
import SwiftRichString

final class DiscoverImageCardView: DiscoverBaseCardView {

    private var imageView: UIImageView!
    private var avatarButton: UIButton!
    private var nameLabel: UILabel!
    private var timeLabel: UILabel!
    private var moreButton: UIButton!
    private var likeButton: UIButton!
    private var commentButton: UIButton!
    private var messageLabel: ExpandableLabel!
    private var locationButton: UIButton!
    
    private var viewModel: DiscoverRecordViewModel?

    override func bindViewModel(_ viewModel: DiscoverRecordViewModel) {
        self.viewModel = viewModel
        
        let url = URL(string: viewModel.model.imageUrl)
        KF.url(url)
            .fade(duration: 0.35)
            .cacheMemoryOnly()
            .set(to: imageView)
        
        if viewModel.model.owner.userAvatar.isEmpty {
            if let title = viewModel.model.owner.userNickName.firstCharacterAsString {
                avatarButton.setNormalAvatar(title: title.uppercased())
                avatarButton.titleLabel?.font = UIFont(type: .montserratRegular, size: 18.rpx * scale)
            }
        } else {
            let url = URL(string: viewModel.model.owner.userAvatar)
            KF.url(url)
                .fade(duration: 0.35)
                .cacheMemoryOnly()
                .set(to: avatarButton, for: .normal)
        }
        
        nameLabel.text = viewModel.model.owner.userNickName
        
        if let date = viewModel.model.createDatetime.dateTime {
            timeLabel.text = date.discoverDateString()
        }
        
        likeButton.setTitle(viewModel.model.likeNum.countFormat(), for: .normal)
        likeButton.isSelected = viewModel.like
        
        commentButton.setTitle(viewModel.model.commentNum.countFormat(), for: .normal)
        
        layoutLocationButton(viewModel: viewModel)
        layoutMessageLabel(viewModel: viewModel)
        
        viewModel.$like
            .assign(to: \.isSelected, on: self.likeButton, ownership: .weak)
            .store(in: &cancellables)
    }

    override func setupViews() {
        
        imageView = UIImageView().then {
            $0.backgroundColor = UIColor.blackVerticalGradient(size: self.size)
            $0.cornerRadius = 15.rpx * self.scale
            $0.contentMode = .scaleAspectFill
            $0.frame = self.bounds
        }
        
        avatarButton = UIButton().then {
            $0.cornerRadius = 20.rpx * self.scale
            $0.contentMode = .scaleAspectFill
            let size = CGSize(width: 40.rpx * self.scale, height: 40.rpx * self.scale)
            let x = 20.rpx * self.scale
            let y = 22.rpx * self.scale
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        nameLabel = UILabel().then {
            $0.textColor = .white
            $0.font = UIFont(type: .montserratBlod, size: 25.rpx * self.scale)
            let x = avatarButton.frame.maxX + 8.rpx * self.scale
            let y = 20.rpx * self.scale
            let width = self.width - 68.rpx * self.scale - x
            let height = String.singleLineHeight(font: $0.font)
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        timeLabel = UILabel().then {
            $0.textColor = .white.withAlphaComponent(0.5)
            $0.font = UIFont(type: .montserratRegular, size: 13.rpx * self.scale)
            let width = nameLabel.width
            let height = String.singleLineHeight(font: $0.font)
            let x = nameLabel.x
            let y = avatarButton.frame.maxY - height + 2.rpx * self.scale
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        moreButton = UIButton().then {
            let image = UIImage(named: "invites_card_more_normal")!
            let scaleImage = image.scaled(toWidth: scale * 28.0)!.scaled(toHeight: scale * 28.0)!
            $0.setImage(scaleImage, for: .normal)
            let size = CGSize(width: 40.rpx * self.scale, height: 40.rpx * self.scale)
            let x = self.width - size.width - 20.rpx * self.scale
            let y = 22.rpx * self.scale
            $0.frame = CGRect(x: x, y: y, size: size)
            $0.setRoundBackgroundColor(UIColor(hexString: "#666666", transparency: 0.4), for: .normal)
        }
        
        likeButton = UIButton().then {
            let image = UIImage(named: "like_normal")!
            let selectedImage = UIImage(named: "like_selected")!
            let scaleImage = image.scaled(toWidth: scale * 40.0)!.scaled(toHeight: scale * 40.0)!
            let scaleSelectedImage = selectedImage.scaled(toWidth: scale * 40.0)!.scaled(toHeight: scale * 40.0)!
            $0.setImage(scaleImage, for: .normal)
            $0.setImage(scaleImage.alpha(0.6), for: [.normal, .highlighted])
            $0.setImage(scaleSelectedImage, for: .selected)
            $0.setImage(scaleSelectedImage.alpha(0.6), for: [.selected, .highlighted])
            $0.setTitle("0", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont(type: .montserratRegular, size: 13.rpx * self.scale)
            let size = CGSize(width: 40.rpx * self.scale, height: 65.rpx * self.scale)
            let x = self.width - size.width - 20.rpx * self.scale
            let y = 250.rpx * self.scale
            $0.frame = CGRect(x: x, y: y, size: size)
            $0.setImageAlign(to: .top(.zero))
        }
        
        commentButton = UIButton().then {
            let image = UIImage(named: "comment_normal")!
            let scaleImage = image.scaled(toWidth: scale * 40.0)!.scaled(toHeight: scale * 40.0)!
            $0.setImage(scaleImage, for: .normal)
            $0.setTitle("0", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont(type: .montserratRegular, size: 13.rpx * self.scale)
            let size = likeButton.size
            let x = likeButton.x
            let y = likeButton.frame.maxY + 25.rpx * self.scale
            $0.frame = CGRect(x: x, y: y, size: size)
            $0.setImageAlign(to: .top(.zero))
        }
        
        messageLabel = ExpandableLabel().then {
            $0.delegate = self
            $0.numberOfLines = 2
            $0.collapsed = true
            $0.shouldCollapse = true
            $0.textColor = .white
            $0.textReplacementType = .word
            $0.font = UIFont(type: .montserratRegular, size: 14.rpx * self.scale)
        }
        
        locationButton = UIButton().then {
            let image = UIImage(named: "discover_card_location_normal")!
            let scaleImage = image.scaled(toWidth: scale * 22.0)!.scaled(toHeight: scale * 22.0)!
            $0.setImage(scaleImage, for: .normal)
            $0.setTitleColor(.white, for: .normal)
        }
        
        avatarButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        addSubviews([imageView,
                     avatarButton,
                     nameLabel,
                     timeLabel,
                     moreButton,
                     likeButton,
                     commentButton,
                     messageLabel,
                     locationButton])
        
    }
    
    private func layoutMessageLabel(viewModel: DiscoverRecordViewModel) {
        let text = viewModel.model.content
        
        let lineHeightMultiple = 1.06
        let font = UIFont(type: .montserratRegular, size: 14.rpx * self.scale)!
        let style = Style {
            $0.lineHeightMultiple = lineHeightMultiple
            $0.font = font
        }
        let width = 190.rpx * scale
        let height = viewModel.contentExpand ? text.height(style: style, containerWidth: width) : (font.lineHeight * lineHeightMultiple * 2)
        let x = 20.rpx * scale
        let y = self.height - 25.rpx * scale - height
        messageLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        
        let linkFont = UIFont(type: .montserratBlod, size: 14.rpx * scale)!
        messageLabel.collapsedAttributedLink = NSAttributedString(string: "More", attributes: [.font: linkFont])
        messageLabel.expandedAttributedLink = NSAttributedString(string: "Less", attributes: [.font: linkFont, .foregroundColor: UIColor.red])
        messageLabel.ellipsis = NSAttributedString(string: "...", attributes: [.font: font])
        
        messageLabel.originAttributedText = text.set(style: style)
    }
    
    private func layoutLocationButton(viewModel: DiscoverRecordViewModel) {
        let text = "3km"
        locationButton.setTitle(text, for: .normal)
        
        let font = UIFont(type: .montserratBlod, size: 16.rpx * self.scale)!
        locationButton.titleLabel?.font = font

        let width = text.width(font: font) + 47.rpx * scale
        let height = 33.rpx * scale
        let x = self.width - width - 20.rpx * scale
        let y = self.height - height - 25.rpx * scale
        locationButton.frame = CGRect(x: x, y: y, width: width, height: height)
       
        locationButton.setImageAlign(to: .left(5.rpx * scale))
        locationButton.setRoundBackgroundColor(UIColor(hexString: "#666666", transparency: 0.4), for: .normal)
    }
    
    @objc private func click(_ sender: UIButton) {
        if sender == avatarButton {
            tapHandler?(.user)
        } else if sender == moreButton {
            tapHandler?(.more)
        } else if sender == likeButton {
            tapHandler?(.like)
        } else if sender == commentButton {
            tapHandler?(.comment)
        }
    }
    
}

extension DiscoverImageCardView: ExpandableLabelDelegate {
    
    func expandableLabel(_ label: ExpandableLabel, needsPerformAction action: ExpandableLabel.Action) {
        switch action {
        case .didExpand:
            guard let viewModel = viewModel else { return }
            viewModel.contentExpand = true
            layoutMessageLabel(viewModel: viewModel)
        case .didCollapse:
            guard let viewModel = viewModel else { return }
            viewModel.contentExpand = false
            layoutMessageLabel(viewModel: viewModel)
        default:
            break
        }
    }
    
}
