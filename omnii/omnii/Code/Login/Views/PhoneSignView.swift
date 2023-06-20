//
//  PhoneSignView.swift
//  omnii
//
//  Created by huyang on 2023/4/26.
//

import UIKit
import CommonUtils
import SwifterSwift

class PhoneSignView: UIView {
    
    // 下一步
    var nextHandler: ((SignupEditType) -> Void)?
    // 上一步
    var backHandler: ((SignupEditType) -> Void)?
    // 返回上一页
    var pop: (() -> Void)?
    
    // 输入变化
    var editChanged: ((SignupEditType, String?) -> Void)? {
        didSet {
            editView.editChanged = editChanged
        }
    }
    
    // 点击事件
    var clickHandler: ((SignupClickType) -> Void)? {
        didSet {
            editView.clickHandler = clickHandler
        }
    }
    
    var isNextEnabled: Bool {
        didSet {
            nextBtn.isEnabled = isNextEnabled
        }
    }
    
    var countryItem: CountryItem? {
        didSet {
            if let item = countryItem {
                editView.setCountryItem(to: item)
            }
        }
    }
            
    private var bar: SignupNavigationBar!
    private var editView: SignupEditView!
    private var nextBtn: UIButton!

    override init(frame: CGRect) {
        self.isNextEnabled = false
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func updateView(to type: SignupEditType) {
        editView.type = type
        setBarProcess(to: type.rawValue)
        showNext(with: type.rawValue)
        bar.isProcessViewHidden = (type.rawValue <= 1)
    }
    
    func resetTimer() {
        editView.resetTimer()
    }
    
    func showWarning(text: String) {
        editView.setWarningText(text: text)
    }
    
    override func becomeFirstResponder() -> Bool {
        return editView.becomeFirstResponder()
    }
    
}

// MARK: - private

extension PhoneSignView {
    
    private func setBarProcess(to index: Int) {
        let diff = editView.editViews.count - bar.count
        self.bar.setProcess(to: index - diff)
    }
    
    private func setupViews() {
        layer.setImage(UIImage(named: "signup_bg"))
        setupBar()
        setupNextBtn()
        setupSignupEditView()
    }
    
    private func setupBar() {
        let y = ScreenFit.statusBarHeight
        let height = ScreenFit.navigationBarHeight
        let frame = CGRect(x: 0, y:y , width: ScreenWidth, height: height)
        bar = SignupNavigationBar(frame: frame, switchCount: 3)
        bar.setProcess(to: 0)
        addSubview(bar)
        
        bar.backHandle = { [unowned self] in
            guard self.editView.type != .phone else {
                if let handler = pop { handler() }
                return
            }
            
            let prevous = self.editView.type.prevous()
            
            guard self.editView.type != prevous else { return }
            
            if let handler = backHandler {
                handler(self.editView.type)
            }
        }
    }
    
    private func setupNextBtn() {
        nextBtn = UIButton(type: .custom)
        nextBtn.isEnabled = false
        nextBtn.size = CGSize(width: 100.rpx, height: 60.rpx)
        nextBtn.x = (ScreenWidth - nextBtn.width) / 2.0
        nextBtn.y = ScreenHeight - 355.rpx - nextBtn.height
        nextBtn.cornerRadius = nextBtn.height / 2.0
        nextBtn.setImageForAllStates(UIImage(named: "signup_next")!)
        nextBtn.setBackgroundImage(UIImage(color: .white, size: nextBtn.size), for: .normal)
        nextBtn.setBackgroundImage(UIImage(color: UIColor(hexString: "#F5F5F5")!, size: nextBtn.size), for: .highlighted)
        nextBtn.setBackgroundImage(UIImage(color: .white.withAlphaComponent(0.3), size: nextBtn.size), for: .disabled)

        addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(clickNext(_:)), for: .touchUpInside)
    }
    
    private func setupSignupEditView() {
        let x = 0.0
        let y = ScreenFit.navigationHeight
        let width = ScreenWidth
        let height = nextBtn.frame.minY - y
        let frame = CGRect(x: x, y: y, width: width, height: height)
        editView = SignupEditView(show: .phone, frame: frame)
        addSubview(editView)
    }
    
    private func showNext(with index: Int) {
        nextBtn.isHidden = false
    }
    
    @objc private func clickNext(_ sender: UIButton) {
        if let handler = nextHandler {
            handler(self.editView.type)
        }
    }
    
}
