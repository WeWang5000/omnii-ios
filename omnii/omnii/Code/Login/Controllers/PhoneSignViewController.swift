//
//  PhoneSignViewController.swift
//  omnii
//
//  Created by huyang on 2023/4/21.
//

import UIKit
import Combine
import CommonUtils
import PopupDialog

class PhoneSignViewController: ViewController {
    
    private let viewModel = SignViewModel()
        
    private var phone: String?
    private var code: String?
    private var name: String?
    private var birthday: String?
    private var gender: String = "Male"
    
    private var cancellable: AnyCancellable?
    
    private lazy var picker = {
        let controller = CountryPickerViewController()
        controller.view.backgroundColor = .black
        controller.view.roundCorners([. topLeft, .topRight], radius: 30.rpx)
        let y = 113.rpx
        controller.view.frame = CGRect(x: 0, y: y, width: ScreenWidth, height: ScreenHeight - y)
       return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = PhoneSignView(frame: UIScreen.main.bounds)
        
        if let item = picker.countryData.first {
            signinView.countryItem = item
        }
        
        signinView.pop = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        // 上一步
        signinView.backHandler = { [unowned self] type in
            self.signinView.updateView(to: type.prevous())
        }
        
        // 下一步
        signinView.nextHandler = { [unowned self] type in
            switch type {
            case .phone:
                self.signinView.showWarning(text: "")
                requestCaptcha()
            case .code:
                requestLogin()
            case .name:
                self.signinView.updateView(to: .birthday)
            case .birthday:
                self.signinView.updateView(to: .gender)
            case .gender:
                requestSupplement()
            }
        }
        
        // 输入变化
        signinView.editChanged = { [unowned self] type, text in
            switch type {
            case .phone:
                self.phone = text
                signinView.isNextEnabled = (text == nil) ? false : !(text!.isEmpty)
            case .code:
                self.code = text
                signinView.isNextEnabled = (text == nil) ? false : (text!.length == 4)
            case .name:
                self.name = text
                signinView.isNextEnabled = (text == nil) ? false : !(text!.isEmpty)
            case .birthday:
                self.birthday = text
                signinView.isNextEnabled = (text == nil) ? false : (text!.length == 10)
            case .gender:
                self.gender = text!
            }
        }
        
        // 点击事件
        signinView.clickHandler = { [unowned self] type in
            switch type {
            case .countryPick:
                self.presentCountryList()
            case .resetTimer:
                requestCaptcha()
                self.signinView.resetTimer()
                break
            }
        }
        
        //  网络请求结果
        cancellable = viewModel.authResult.sink { [unowned self] result in
            switch result {
            case .captchaSucceeded:
                self.signinView.updateView(to: .code)
                self.signinView.resetTimer()
            case .loginSucceeded(let model):
                if model.nickname.length > 0 {
                    self.toStartedController()
                } else {
                    self.signinView.updateView(to: .name)
                }
            case .supplementSucceeded:
                self.toStartedController()
            case .captchaFailure(let error):
                self.signinView.showWarning(text: error.localizedDescription)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = signinView.becomeFirstResponder()
    }
    
    var signinView: PhoneSignView! {
        return view as? PhoneSignView
    }
    
}

extension PhoneSignViewController {
    
    private func requestCaptcha() {
        guard let phone = phone, let area = signinView.countryItem?.dialCode else { return }
        self.viewModel.input.captcha(prefix: area.removing(prefix: "+"), phone: phone)
    }
    
    private func requestLogin() {
        guard let code = code else { return }
        self.viewModel.input.login(code: code)
    }
    
    private func requestSupplement() {
        guard let name = name, let birthday = birthday else { return }
        self.viewModel.input.supplement(nickname: name, birthday: birthday, gender: gender.lowercased())
    }
    
    private func presentCountryList() {
        self.present(picker, transionStyle: .sheet, tapGestureDismissal: true, panGestureDismissal: true)
        picker.pickResult = { [unowned self] item in
            self.signinView.countryItem = item
            picker.dismiss(animated: true)
        }
    }
    
    private func toStartedController() {
        self.navigationController?.pushViewController(StartedViewController())
    }
    
}
