//
//  InvitesLimitController.swift
//  omnii
//
//  Created by huyang on 2023/6/9.
//

import UIKit
import CommonUtils
import SwiftRichString

final class InvitesLimitController: UIViewController, UITextFieldDelegate {
    
    var complete: ((Int) -> Void)?
    
    private var navigationBar: NavigationBar!
    private var titleLabel: UILabel!
    private var textField: UITextField!
    private var descLabel: UILabel!
    private var completeButton: UIButton!
    
    private let keyboard = KeyboardManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        setupViews()
        
        keyboard.action = { [unowned self] event in
            switch event {
            case .willShow(let info):
                let y = info.endFrame.origin.y
                UIView.animate(withDuration: info.duration) {
                    self.completeButton.y = y - self.completeButton.height - 10.rpx
                }
            case .willHide(let info):
                UIView.animate(withDuration: info.duration) {
                    self.completeButton.y = ScreenHeight - ScreenFit.safeBottomHeight - self.completeButton.height
                }
            default:
                break
            }
        }
        
        navigationBar.backAction = { [unowned self] in
            self.dismiss()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard.registerMonitor()
        textField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboard.unregisterMonitor()
    }

    private func setupViews() {
        
        navigationBar = NavigationBar().then {
            $0.title = "Set limit"
            $0.backStyle = .close
        }
        
        titleLabel = UILabel().then {
            $0.text = "Number of invited people"
            $0.textColor = .white
            $0.font = UIFont(type: .montserratRegular, size: 23.rpx)
            let x = 20.rpx
            let y = navigationBar.frame.maxY
            let width = ScreenWidth - x * 2
            let height = 30.rpx
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        textField = UITextField().then {
            let placeholderStyle = Style {
                $0.font = UIFont(type: .montserratBlod, size: 25.rpx)
                $0.color = Color(hexString: "#FFFFFF", transparency: 0.3)
            }
            $0.attributedPlaceholder = "1~12".set(style: placeholderStyle)
            $0.textColor = .white
            $0.font = UIFont(type: .montserratBlod, size: 25.rpx)
            $0.tintColor = UIColor(hexString: "#5367E2")
            $0.keyboardType = .decimalPad
            $0.delegate = self
            let x = 20.rpx
            let y = titleLabel.frame.maxY + 30.rpx
            let width = ScreenWidth - x * 2
            let height = 46.rpx
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        descLabel = UILabel().then {
            $0.text = "The maximum number of people who can be invited is 12"
            $0.textColor = .white.withAlphaComponent(0.5)
            $0.font = UIFont(type: .montserratRegular, size: 14.rpx)
            $0.numberOfLines = 0
            let x = 20.rpx
            let y = textField.frame.maxY + 30.rpx
            let width = ScreenWidth - x * 2
            let height = 35.rpx
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        completeButton = UIButton(type: .custom).then {
            $0.isEnabled = false
            let size = CGSize(width: 320.rpx, height: 55.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = ScreenHeight - ScreenFit.safeBottomHeight - size.height
            $0.frame = CGRect(x: x, y: y, size: size)
            $0.whiteBackgroundStyle(title: "Complete")
        }
        
        completeButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubviews([navigationBar, titleLabel, textField, descLabel, completeButton])
    }
    
    private func dismiss() {
        self.dismiss(animated: true)
    }
    
    @objc private func click(_ sender: UIButton) {
        var count = 0
        if let text = textField.text {
            count = Int(text) ?? 0
        }
        
        if count > 12 {
            self.descLabel.textColor = .red
            self.descLabel.shake()
            return
        }
        
        complete?(count)
    }
 
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            completeButton.isEnabled = !text.isEmpty
        } else {
            completeButton.isEnabled = false
        }
    }
    
}
