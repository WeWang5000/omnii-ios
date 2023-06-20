//
//  CoverMessageController.swift
//  omnii
//
//  Created by huyang on 2023/5/24.
//

import UIKit
import CommonUtils
import SwiftRichString

class CoverMessageController: UIViewController {

    private var message: String
    
    required init(message: String) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black.withAlphaComponent(0.8)
        setupViews()
    }
    
    private func setupViews() {
        
        let label = UILabel().then {
            let font = UIFont(type: .montserratMedium, size: 20.rpx)
            let width = 224.rpx
            let x = (ScreenWidth - width) / 2.0
            let y = 342.rpx
            let attrs: [NSAttributedString.Key : Any] = [.font: font!]
            let height = self.message.height(attributes: attrs, containerWidth: width)
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
            $0.text = self.message
            $0.font = font
            $0.textColor = .white
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        let button = UIButton(type: .custom).then {
            let size = CGSize(width: 170.rpx, height: 55.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = label.frame.maxY + 24.rpx
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            let bgImage = UIImage(color: .white, size: size).withRoundedCorners()
            if let image = bgImage {
                $0.setBackgroundImage(image, for: .normal)
            }
            let style = Style {
                $0.alignment = .center
                $0.font = UIFont(type: .montserratBlod, size: 18.rpx)
                $0.color = UIColor(hexString: "#010101")
            }
            let text = "Got it".set(style: style)
            $0.setAttributedTitle(text, for: .normal)
        }
        
        button.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubview(label)
        view.addSubview(button)
    }
    
    @objc private func click(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
