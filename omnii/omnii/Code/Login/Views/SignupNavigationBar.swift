//
//  SignupNavigationBar.swift
//  omnii
//
//  Created by huyang on 2023/4/21.
//

import UIKit

class SignupNavigationBar: UIView {
    
    var backHandle: (() -> Void)?
    
    var isProcessViewHidden: Bool {
        didSet {
            tagViews.forEach { layer in
                layer.isHidden = isProcessViewHidden
            }
        }
    }
    
    private let tagNomalColor = UIColor.white.withAlphaComponent(0.3).cgColor
    private let tagSelectedColor = UIColor.white.cgColor
    
    private var tagViews: [CALayer] = {
       return [CALayer]()
    }()
    
    private(set) var count: Int
    
    init(frame: CGRect, switchCount: Int) {
        self.count = switchCount
        self.isProcessViewHidden = true
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProcess(to index: Int) {
        if index < 0 || index >= tagViews.count { return }
        for (i, tag) in tagViews.enumerated() {
            if i <= index {
                tag.backgroundColor = tagSelectedColor
            } else {
                tag.backgroundColor = tagNomalColor
            }
        }
    }
    
}

// MARK: - UI
private extension SignupNavigationBar {
    
    private func setupViews() {
        setupBackItem()
        setupTagLayers(count: count)
    }
    
    private func setupBackItem() {
        let backBtn = UIButton(type: .custom)
        let width = 28.rpx
        let height = 28.rpx
        let x = 10.rpx
        let y = (self.height - height) / 2.0
        backBtn.frame = CGRect(x: x, y: y, width: width, height: height)
        if let image = UIImage(named: "back_normal") {
            backBtn.setImage(image, for: .normal)
        }
        if let image = UIImage(named: "back_highlight") {
            backBtn.setImage(image, for: .highlighted)
        }
        addSubview(backBtn)
        backBtn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
    }
    
    private func setupTagLayers(count: Int) {
        if count < 1 { return }
        
        let spacing = 5.rpx
        let width = 55.rpx
        let height = 4.rpx
        let totalWidth = count.double * width + (count - 1).double * spacing
        let x = (self.width - totalWidth) / 2.0
        let y = (self.height - height) / 2.0
        let moveX = width + spacing
        
        for i in 1...count {
            let rx = x + moveX * (i - 1).double
            let tag = tagLayer()
            tag.frame = CGRect(x: rx, y: y, width: width, height: height)
            layer.addSublayer(tag)
            tagViews.append(tag)
        }
        
    }
    
    private func tagLayer() -> CALayer {
        let layer = CALayer()
        layer.isHidden = true
        layer.cornerRadius = 2.5.rpx
        layer.backgroundColor = tagNomalColor
        return layer
    }
    
    @objc private func click(_ sender: UIButton) {
        if let handle = backHandle {
            handle()
        }
    }
    
}
