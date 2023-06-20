//
//  InvitesEditingView.swift
//  omnii
//
//  Created by huyang on 2023/5/25.
//

import UIKit
import CommonUtils

final class InvitesEditingView: UIView {
    
    enum Event {
        case touchTime
        case touchLocation
        case touchTimeAndLocation
    }
    
    var editAction: ((Event) -> Void)?
    
    var textDidChange: ((String) -> Void)? {
        didSet { textView.textDidChange = textDidChange }
    }
    
    var isEnabled: Bool {
        get {
            textView.isEnabled &&
            timeEditButton.isEnabled &&
            locationEditButton.isEnabled
        }
        set {
            textView.isEnabled = newValue
            timeEditButton.isEnabled = newValue
            locationEditButton.isEnabled = newValue
            textView.isHiddenLimitLabel = !newValue
        }
    }
    
    private var textView: InvitesTextView!
    private var timeEditButton: InvitesBorderButton!
    private var locationEditButton: InvitesBorderButton!
    private var timeAndLocationbutton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    func setTimeAndLocationButtonHidden(_ hidden: Bool) {
        if !timeEditButton.isHidden { return }
        timeAndLocationbutton.isHidden = hidden
    }
    
    func update(date: Date, location: GeoModel) {
        timeEditButton.isHidden = false
        locationEditButton.isHidden = false
        timeAndLocationbutton.isHidden = true
        updateTime(date)
        updateLocation(location)
    }
    
    func updateTime(_ date: Date) {
        let time = date.invitesTime()
        timeEditButton.title = time.0
        timeEditButton.content = time.1
    }

    func updateLocation(_ location: GeoModel) {
        locationEditButton.title = location.name
        locationEditButton.content = location.description
    }
    
    private func setupViews() {
        
        let x = 20.rpx
        let y = 5.0
        let width = ScreenWidth - x * 2
        let height = 50.rpx
        textView = InvitesTextView(frame: CGRect(x: x, y: y, width: width, height: height), placeholder: "What are we doing？")
        
        timeEditButton = InvitesBorderButton().then {
            $0.isHidden = true
            $0.image = UIImage(named: "invites_time")
            $0.title = "Time"
            let x = 22.rpx
            let y = textView.frame.maxY + 24.rpx
            let size = CGSize(width: 160.rpx, height: 50.rpx)
            $0.frame = CGRect(x: x, y: y, size: size)
        }

        locationEditButton = InvitesBorderButton().then {
            $0.isHidden = true
            $0.image = UIImage(named: "invites_location")
            $0.title = "Location"
            let size = CGSize(width: 160.rpx, height: 50.rpx)
            let x = ScreenWidth - 22.rpx - size.width
            let y = timeEditButton.y
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        timeAndLocationbutton = UIButton(type: .custom).then {
            let title = "Set Time & Location"
            let font = UIFont(type: .montserratRegular, size: 20.rpx)!
            let color = UIColor.textGradient(size: title.size(font: font))
            $0.cornerRadius = 10.rpx
            $0.borderWidth = 1.0
            $0.borderColor = .white.withAlphaComponent(0.1)
            $0.setImage(UIImage(named: "invites_location_time"), for: .normal)
            $0.setTitleColor(color, for: .normal)
            $0.setTitle(title, for: .normal)
            $0.setImageAlign(to: .left(12.rpx))
            $0.titleLabel?.font = font
            let x = 22.rpx
            let y = textView.frame.maxY + 24.rpx
            let width = ScreenWidth - x * 2
            let height = 60.rpx
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        textView.heightChanged = { [unowned self] height in
            self.timeEditButton.y = height + 24.rpx
            self.locationEditButton.y = height + 24.rpx
            self.timeAndLocationbutton.y = height + 24.rpx
        }
        
        timeEditButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        locationEditButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        timeAndLocationbutton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        addSubviews([textView, timeEditButton, locationEditButton, timeAndLocationbutton])
    }
    
    @objc private func click(_ sender: UIButton) {
        if sender == timeEditButton {
            editAction?(.touchTime)
        } else if sender == locationEditButton {
            editAction?(.touchLocation)
        } else if sender == timeAndLocationbutton {
            editAction?(.touchTimeAndLocation)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        textView.resignFirstResponder()
    }
}


private class InvitesLocationTimeButton: UIControl {

    override var isHighlighted: Bool {
        didSet {
            leftView.alpha = isHighlighted ? 0.7 : 1.0
            titleLabel.alpha = isHighlighted ? 0.7 : 1.0
            rightView.alpha = isHighlighted ? 0.7 : 1.0
        }
    }

    private var leftView: UIImageView!
    private var titleLabel: UILabel!
    private var rightView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        cornerRadius = 10.rpx
        borderColor = .white.withAlphaComponent(0.15)
        borderWidth = 1.0

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        leftView.do {
            let size = CGSize(width: 28.rpx, height: 28.rpx)
            let x = 10.rpx
            let y = (self.height - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }

        titleLabel.do {
            let size = $0.size
            let x = leftView.frame.maxX + 10.rpx
            let y = (self.height - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }

        rightView.do {
            let size = CGSize(width: 28.rpx, height: 28.rpx)
            let x = self.width - 10.rpx - size.width
            let y = (self.height - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }

    }

    private func setupViews() {

        leftView = UIImageView().then {
            $0.image = UIImage(named: "invites_location_time")
            $0.contentMode = .center
        }

        titleLabel = UILabel().then {
            let title = "Set Time & Location"
            let font = UIFont(type: .montserratRegular, size: 20.rpx)
            let size = title.size(font: font!)
            $0.text = title
            $0.textColor = UIColor.textGradient(size: size)
            $0.size = size
        }

        rightView = UIImageView().then {
            $0.image = UIImage(named: "invites_btn_arrow")
            $0.contentMode = .center
        }

        addSubviews([leftView, titleLabel, rightView])
    }

}
