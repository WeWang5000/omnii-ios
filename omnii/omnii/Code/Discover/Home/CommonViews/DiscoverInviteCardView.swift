//
//  DiscoverInviteCardView.swift
//  omnii
//
//  Created by huyang on 2023/6/12.
//

import UIKit
import Kingfisher

class DiscoverInviteCardView: DiscoverBaseCardView {
    
    private var avatarButton: UIButton!
    private var nameLabel: UILabel!
    private var timeLabel: UILabel!
    private var moreButton: UIButton!
    private var inquiresButton: UIButton!
    private var messageLabel: UILabel!
    private var dateButton: InvitesBorderButton!
    private var locationButton: InvitesBorderButton!
    private var ispaceButton: UIButton!
    private var attendingLabel: UILabel!
    private var attendingViews: [UIButton] = [UIButton]()
    
    override func bindViewModel(_ viewModel: DiscoverRecordViewModel) {
        avatarButton.setImage(UIImage(named: "avatar_default_normal"), for: .normal)
        nameLabel.text = "Jimmiey"
        messageLabel.text = viewModel.model.content
        locationButton.update(title: viewModel.model.name, content: viewModel.model.description)
        
        if let createDate = viewModel.model.createDatetime.dateTime {
            timeLabel.text = createDate.discoverDateString()
        }
        
        if let appointedDate = viewModel.model.appointedTime.dateTime {
            let time = appointedDate.invitesTime()
            dateButton.update(title: time.0, content: time.1)
        }
        
        if let layout = self.scale.isLess(than: 1.0) ? viewModel.contentHorizontalLayout : viewModel.contentVerticalLayout {
            let attString = NSAttributedString(string: viewModel.model.content, attributes: layout.attrs)
            messageLabel.attributedText = attString
            messageLabel.height = layout.height
            dateButton.y = messageLabel.frame.maxY + 20.rpx * scale
            locationButton.y = messageLabel.frame.maxY + 20.rpx * scale
        }
        
        if !viewModel.model.participatedUsers.isEmpty {
            attendingLabel.text = "\(viewModel.model.participatedUsers.count)/\(viewModel.model.participatedNum) Attending"
            layoutInviteAvatars(for: [friend(id: "1"), friend(id: "2"), friend(id: "3"), friend(id: "4")])
        }
    }
    
    private func friend(id: String) -> FriendModel {
        var friend = FriendModel(userId: id, userOmniiNo: "233\(id)")
        friend.userAvatar = "https://c-ssl.dtstatic.com/uploads/item/202004/24/20200424190223_GdiFC.thumb.1000_0.jpeg"
        friend.userNickName = "asdjbnkuhbn\(id)"
        friend.relationshipIsNew = true
        return friend
    }
    
    override func setupViews() {
        
        backgroundColor = UIColor.blackVerticalGradient(size: size)
        cornerRadius = 15.rpx * scale
        
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
        
        inquiresButton = UIButton().then {
            let image = UIImage(named: "discover_qa_normal")!
            let scaleImage = image.scaled(toWidth: scale * 40.0)!.scaled(toHeight: scale * 40.0)!
            $0.setImage(scaleImage, for: .normal)
            let size = CGSize(width: 40.rpx * scale, height: 40.rpx * scale)
            let x = moreButton.x
            let y = moreButton.frame.maxY + 10.rpx * scale
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        messageLabel = UILabel().then {
            $0.numberOfLines = 0
            $0.textColor = .white
            $0.font = UIFont(type: .montserratBlod, size: 25.rpx * scale)
            let x = 20.rpx * scale
            let y = avatarButton.frame.maxY + 100.rpx * scale
            let size = CGSize(width: 315.rpx * scale, height: 70.rpx * scale)
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        dateButton = InvitesBorderButton().then {
            let image = UIImage(named: "invites_time")!
            let scaleImage = image.scaled(toWidth: scale * 28.0)!.scaled(toHeight: scale * 28.0)!
            $0.image = scaleImage
            let x = 12.rpx * scale
            let y = messageLabel.frame.maxY + 20.rpx * scale
            let size = CGSize(width: 160.rpx * scale, height: 50.rpx * scale)
            $0.frame = CGRect(x: x, y: y, size: size)
            $0.scale = scale
        }

        locationButton = InvitesBorderButton().then {
            let image = UIImage(named: "invites_location")!
            let scaleImage = image.scaled(toWidth: scale * 28.0)!.scaled(toHeight: scale * 28.0)!
            $0.image = scaleImage
            let x = dateButton.frame.maxX + 10.rpx * scale
            let y = dateButton.y
            let size = dateButton.size
            $0.frame = CGRect(x: x, y: y, size: size)
            $0.scale = scale
        }
        
        ispaceButton = UIButton(type: .custom).then {
            let size = CGSize(width: 162.rpx * scale, height: 55.rpx * scale)
            let x = self.width - size.width - 10.rpx * scale
            let y = self.height - size.height - 25.rpx * scale
            $0.frame = CGRect(x: x, y: y, size: size)
            let image = UIImage(named: "discover_card_arrow")!
            let scaleImage = image.scaled(toWidth: 14.rpx * scale)!.scaled(toHeight: 13.rpx * scale)!
            $0.setImageForAllStates(scaleImage)
            $0.whiteBackgroundStyle(title: "Enter ispace")
            $0.titleLabel?.font = UIFont(type: .montserratBlod, size: 15.rpx * scale)
            $0.setImageAlign(to: .right(10.rpx * scale))
        }
        
        attendingLabel = UILabel().then {
            $0.isHidden = true
            $0.textColor = .white
            $0.font = UIFont(type: .montserratRegular, size: 16.rpx * scale)
            let x = 20.rpx * scale
            let y = 528.rpx * scale
            let size = CGSize(width: 120.rpx * scale, height: 15.rpx * scale)
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        for i in 0...3 {
            let button = UIButton(type: .custom).then {
                $0.isHidden = true
                let x = 20.rpx * scale + Double(i) * 30.rpx * scale
                let y = attendingLabel.frame.maxY + 15.rpx * scale
                let size = CGSize(width: 40.rpx * scale, height: 40.rpx * scale)
                $0.frame = CGRect(x: x, y: y, size: size)
                let image = UIImage(named: "discover_add_normal")!
                let scaleImage = image.scaled(toWidth: scale * 28.0)!.scaled(toHeight: scale * 28.0)!
                $0.setImage(scaleImage, for: .normal)
                $0.setRoundBackgroundColor(UIColor(hexString: "#666666", transparency: 0.6), for: .normal)
            }
            
            button.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
            
            attendingViews.append(button)
        }
        
        avatarButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        inquiresButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        ispaceButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)

        addSubviews([avatarButton,
                     nameLabel,
                     timeLabel,
                     moreButton,
                     inquiresButton,
                     messageLabel,
                     dateButton,
                     locationButton,
                     ispaceButton,
                     attendingLabel])
        
        addSubviews(attendingViews)
    }
    
    private func layoutInviteAvatars(for friends: [FriendModel]) {
        
        attendingLabel.isHidden = friends.isEmpty
        
        let count = min(friends.count, 4)
        for (i, button) in attendingViews.enumerated() {
            guard i < count else { return }
            
            button.isHidden = false
            
            if i > 2 { return }
            
            let friend = friends[i]
            let url = URL(string: friend.userAvatar)
            let placeholder = UIImage(named: "avatar_default_normal")
            KF.url(url)
                .placeholder(placeholder)
                .fade(duration: 0.35)
                .cacheMemoryOnly()
                .set(to: button, for: .normal)
            
        }
        
    }
    
    @objc private func click(_ sender: UIButton) {
        
        if sender == avatarButton {
            tapHandler?(.user)
        } else if sender == moreButton {
            tapHandler?(.more)
        } else if sender == inquiresButton {
            tapHandler?(.inquires)
        } else if sender == ispaceButton {
            tapHandler?(.ispace)
        } else if attendingViews.contains([sender]) {
            tapHandler?(.attending)
        }
        
    }

}
