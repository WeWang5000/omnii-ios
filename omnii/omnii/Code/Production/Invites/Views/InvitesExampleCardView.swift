//
//  InvitesExampleCardView.swift
//  omnii
//
//  Created by huyang on 2023/5/24.
//

import UIKit
import CommonUtils
import SwiftRichString

class InvitesExampleCardView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let start = UIColor(hexString: "#323232")
        let end = UIColor(hexString: "#1C1C1C")
        backgroundColor = UIColor(gradientColors: [start, end], bounds: bounds, direction: .vertical)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    private func setupViews() {
        
        let avatar = UIImage(named: "avatar_default_normal")
        let avatarView = UIImageView(image: avatar).then {
            let size = CGSize(width: 50.rpx, height: 50.rpx)
            let x = 20.rpx
            let y = 20.rpx
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        }
        
        let nameLabel = UILabel().then {
            let name = "Jimmy"
            $0.text = name
            $0.textColor = .white
            $0.textAlignment = .left
            let font = UIFont(type: .montserratBlod, size: 20.rpx)
            $0.font = font
            let x = avatarView.frame.maxX + 10.rpx
            let y = avatarView.y + 5.rpx
            let size = name.size(font: font!)
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        }
        
        let moreButton = UIButton(imageName: "invites_card_more").then {
            let size = CGSize(width: 50.rpx, height: 28.rpx)
            let x = self.width - 20.rpx - size.width
            let y = avatarView.y + (avatarView.height - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
            $0.setRoundBackgroundColor(.white.withAlphaComponent(0.15), for: .normal)
        }
        
        let timeLabel = UILabel().then {
            let text = "3 mins ago"
            $0.text = text
            $0.textAlignment = .left
            $0.textColor = .white.withAlphaComponent(0.5)
            $0.font = UIFont(type: .montserratRegular, size: 14.rpx)
            let x = nameLabel.x
            let y = nameLabel.frame.maxY + 5.rpx
            let size = text.size(font: $0.font)
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        }
        
        let x = 20.rpx
        let y = avatarView.frame.maxY + 35.rpx
        let width = ScreenWidth - x * 2
        let height = 80.rpx
        let textView = InvitesTextView(frame: CGRect(x: x, y: y, width: width, height: height)).then {
            $0.isEnabled = false
            $0.text = "Come join me for Jazz night and drinks!"
        }
        
        let timeEditButton = InvitesBorderButton().then {
            $0.image = UIImage(named: "invites_time")
            $0.title = "Tommorrow"
            $0.content = "2PM"
            let x = 22.rpx
            let y = textView.frame.maxY + 20.rpx
            let size = CGSize(width: 143.rpx, height: 50.rpx)
            $0.frame = CGRect(x: x, y: y, size: size)
        }

        let locationEditButton = InvitesBorderButton().then {
            $0.image = UIImage(named: "invites_location")
            $0.title = "San Francisco"
            $0.content = "Pier39 Lobster..."
            let size = CGSize(width: 143.rpx, height: 50.rpx)
            let x = timeEditButton.frame.maxX + 8.rpx
            let y = timeEditButton.y
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        addSubviews([avatarView,
                     nameLabel,
                     timeLabel,
                     moreButton,
                     textView,
                     timeEditButton,
                     locationEditButton
                    ])
        
    }
    
}
