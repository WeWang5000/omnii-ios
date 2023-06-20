//
//  LoginViewController.swift
//  omnii
//
//  Created by huyang on 2023/4/20.
//

import UIKit
import CommonUtils
import Combine
import PermissionsKit

class LoginViewController: ViewController {
    
    private let viewModel = AppleSignViewModel()
    
    private var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.setImage(UIImage(named: "login_bg"))
        setupViews()
        
        viewModel.input.addAuthorizationObserver()
        
        cancellable = viewModel.output.authResult.sink { result in
            switch result {
            case .loginSucceeded(_):
                self.toStartedController()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupViews() {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        let loginView = LoginView(frame: frame)
        loginView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(loginView)
        
        loginView.actionHandler = { [unowned self] type in
            switch type {
            case .apple:
                viewModel.input.loginWithApple(anchor: view.window)
            case .phone:
                self.navigationController?.pushViewController(PhoneSignViewController())
            }
        }
    }
    
    private func toStartedController() {
        self.navigationController?.pushViewController(StartedViewController())
    }
    
}

