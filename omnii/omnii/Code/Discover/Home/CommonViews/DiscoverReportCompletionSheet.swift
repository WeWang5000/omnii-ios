//
//  DiscoverReportCompletionSheet.swift
//  omnii
//
//  Created by huyang on 2023/6/16.
//

import UIKit
import CommonUtils

class DiscoverReportCompletionSheet: UIViewController {

    private var headerView: PickerHeaderView!
    private var imageView: UIImageView!
    private var msgLabel: UILabel!
    private var subMsgLabel: UILabel!
    private var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    private func setupViews() {
        
        let bgColor = UIColor(hexString: "#151517")
        view.backgroundColor = bgColor
        
        headerView = PickerHeaderView(frame: .zero).then {
            $0.backgroundColor = bgColor
            $0.frame = CGRect(origin: .zero, size: CGSize(width: ScreenWidth, height: 40.rpx))
        }
        
        imageView = UIImageView().then {
            $0.image = UIImage(named: "discover_report_ok")
            $0.contentMode = .center
            let size = CGSize(width: 54.rpx, height: 54.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = 60.rpx
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        msgLabel = UILabel().then {
            let text = "We've received your report."
            let font = UIFont(type: .montserratBlod, size: 18.rpx)!
            $0.text = text
            $0.textAlignment = .center
            $0.font = font
            $0.textColor = .white
            let x = 10.rpx
            let y = imageView.frame.maxY + 20.rpx
            let widht = ScreenWidth - x * 2
            let height = text.height(font: font)
            $0.frame = CGRect(x: x, y: y, width: widht, height: height)
        }
        
        subMsgLabel = UILabel().then {
            let text = "Thank you for helping keep Omnii safe."
            let font = UIFont(type: .montserratRegular, size: 14.rpx)!
            $0.text = text
            $0.textAlignment = .center
            $0.font = font
            $0.textColor = .white.withAlphaComponent(0.5)
            $0.numberOfLines = 0
            let widht = 200.rpx
            let x = (ScreenWidth - widht) / 2.0
            let y = msgLabel.frame.maxY + 10.rpx
            let height = text.height(font: font, containerWidth: widht)
            $0.frame = CGRect(x: x, y: y, width: widht, height: height)
        }
        
        button = UIButton(type: .custom).then {
            let size = CGSize(width: 320.rpx, height: 55.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            $0.frame = CGRect(x: x, y: 233.rpx, size: size)
            $0.whiteBackgroundStyle(title: "Done")
        }
        
        button.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        let height = 288.rpx + ScreenFit.safeBottomHeight
        let y = ScreenHeight - height
        view.frame = CGRect(x: .zero, y: y, width: ScreenWidth, height: height)
        
        view.addSubviews([headerView, imageView, msgLabel, subMsgLabel, button])
    }
    
    @objc private func click(_ sender: UIButton) {
        dismiss(animated: true)
    }

}
