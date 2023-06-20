//
//  CameraView.swift
//  omnii
//
//  Created by huyang on 2023/5/8.
//

import UIKit
import AVFoundation
import SwifterSwift
import CommonUtils

enum CameraActionType {
    case camera                             // 拍摄
    case edit                               // 纯文本
    case close                              // 关闭
    case flash(AVCaptureDevice.FlashMode)   // 闪光灯
    case info                               // 信息
    case device(CameraDevice)               // 前后置摄像头
    case ablum                              // 相册
}

class CameraView: UIView {
    
    var cameraAction: ((CameraActionType) -> Void)?
    
    private(set) var cameraView: UIView!
    private var cameraButton: UIButton!
    private var editButton: UIButton!
    
    // header
    private var closeButton: UIButton!
    private var flashModeButton: UIButton!
    private var infoButton: UIButton!
    
    // bottom
    private(set) var ablumButton: UIButton!
    private var deviceButton: UIButton!
    
    private var isDeviceBack: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAblumImage(_ image: UIImage) {
        ablumButton.setImage(image, for: .normal)
    }
    
    func updateFlash(mode: AVCaptureDevice.FlashMode) {
        flashModeButton.isSelected = (mode == .on)
    }
    
}

extension CameraView {
    
    private func setupViews() {
        backgroundColor = .black
        
        cameraView = UIView().then {
            $0.cornerRadius = 20.rpx
            let x = 0.0
            let y = ScreenFit.statusBarHeight
            let width = ScreenWidth
            let height = ScreenHeight - ScreenFit.statusBarHeight - 66.rpx - ScreenFit.safeBottomHeight
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
            $0.backgroundColor = .black
        }
        
        cameraButton = UIButton(imageName: "camera").then({ btn in
            let size = CGSize(width: 75.rpx, height: 75.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = cameraView.frame.maxY - 20.rpx - size.height
            btn.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            let bgColor = UIColor.black.withAlphaComponent(0.4)
            let bgImage = UIImage(color: bgColor, size: size).withRoundedCorners()
            if let image = bgImage {
                btn.setBackgroundImage(image, for: .normal)
            }
        })
        
        editButton = UIButton(imageName: "camer_edit").then({ btn in
            let size = CGSize(width: 40.rpx, height: 40.rpx)
            let x = 20.rpx
            let y = cameraView.y + (cameraView.height - size.height) / 2.0
            btn.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            let bgColor = UIColor.black.withAlphaComponent(0.4)
            let bgImage = UIImage(color: bgColor, size: size).withRoundedCorners()
            if let image = bgImage {
                btn.setBackgroundImage(image, for: .normal)
            }
        })
        
        closeButton = UIButton(imageName: "camera_close").then({ btn in
            let size = CGSize(width: 40.rpx, height: 40.rpx)
            let x = 20.rpx
            let y = cameraView.y + 20.rpx
            btn.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            let bgColor = UIColor.black.withAlphaComponent(0.4)
            let bgImage = UIImage(color: bgColor, size: size).withRoundedCorners()
            if let image = bgImage {
                btn.setBackgroundImage(image, for: .normal)
            }
        })
        
        flashModeButton = UIButton(imageName: "camera_flash").then({ btn in
            let size = CGSize(width: 40.rpx, height: 40.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = closeButton.y
            btn.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            let bgColor = UIColor.black.withAlphaComponent(0.4)
            let bgImage = UIImage(color: bgColor, size: size).withRoundedCorners()
            if let image = bgImage {
                btn.setBackgroundImage(image, for: .normal)
            }
        })
        
        infoButton = UIButton(imageName: "camera_info").then({ btn in
            let size = CGSize(width: 40.rpx, height: 40.rpx)
            let x = ScreenWidth - size.width - 20.rpx
            let y = closeButton.y
            btn.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            let bgColor = UIColor.black.withAlphaComponent(0.4)
            let bgImage = UIImage(color: bgColor, size: size).withRoundedCorners()
            if let image = bgImage {
                btn.setBackgroundImage(image, for: .normal)
            }
        })
        
        ablumButton = UIButton(type: .custom).then({ btn in
            btn.cornerRadius = 6.rpx
            btn.contentMode = .scaleAspectFit
            let size = CGSize(width: 34.rpx, height: 34.rpx)
            let x = 30.rpx
            let y = cameraView.frame.maxY + 15.rpx
            btn.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        })
        
        deviceButton = UIButton(imageName: "camera_switch").then({ btn in
            let size = CGSize(width: 34.rpx, height: 34.rpx)
            let x = ScreenWidth - size.width - 30.rpx
            let y = cameraView.frame.maxY + 15.rpx
            btn.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        })
        
        cameraButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        flashModeButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        ablumButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        deviceButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        addSubviews([cameraView,
                     cameraButton,
                     editButton,
                     closeButton,
                     flashModeButton,
                     infoButton,
                     ablumButton,
                     deviceButton])
    }
    
    @objc private func click(_ sender: UIButton) {
        
        guard let action = cameraAction else { return }
        
        if sender == cameraButton {
            action(.camera)
        } else if sender == editButton {
            action(.edit)
        } else if sender == closeButton {
            action(.close)
        } else if sender == flashModeButton {
            sender.isSelected.toggle()
            action(.flash(sender.isSelected ? .on : .off))
        } else if sender == infoButton {
            action(.info)
        } else if sender == ablumButton {
            action(.ablum)
        } else if sender == deviceButton {
            isDeviceBack.toggle()
            action(.device(isDeviceBack ? .back : .front))
        }
        
    }
    
}
