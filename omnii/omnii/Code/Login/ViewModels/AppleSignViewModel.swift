//
//  AppleSignViewModel.swift
//  omnii
//
//  Created by huyang on 2023/4/28.
//

import UIKit
import CommonUtils
import Combine
import AuthenticationServices


protocol AppleSignViewModelInputs {
    
    // login
    func loginWithApple(anchor: ASPresentationAnchor?)
    
    // Apple ID 注册通知
    func addAuthorizationObserver()
    
}

protocol AppleSignViewModelOutputs {
    
    var authResult: AnyPublisher<AppleSignViewModel.Result, Never> { get }
    
}


final class AppleSignViewModel: NSObject {
    
    enum Result {
        case loginSucceeded(AuthModel)
        case failure(Error)
    }
        
    var input: AppleSignViewModelInputs { self }
    var output: AppleSignViewModelOutputs { self }
    
    private let signViewModel = SignViewModel()
    private var cancellable: AnyCancellable?
    
    fileprivate var presentationAnchor: ASPresentationAnchor?
    
    private let authSubject = PassthroughSubject<AppleSignViewModel.Result, Never>()
    let authResult: AnyPublisher<AppleSignViewModel.Result, Never>
    
    override init() {
        self.authResult = authSubject.eraseToAnyPublisher()
        super.init()
        
        mapResult()
    }
    
}

extension AppleSignViewModel: AppleSignViewModelInputs {
    
    func loginWithApple(anchor: ASPresentationAnchor?) {
        
        if let _ = KeychainItem.currentAppleUserIdentifier {
            
            // Apple UI 添加的锚点
            setPresentationAnchor(anchor)
            
            // 重复登录，授权验证
            performExistingAccountSetupFlows()
            
        } else {
            
            // 首次请求
            signupWithAppleID()
            
        }
        
    }
    
    private func setPresentationAnchor(_ anchor: ASPresentationAnchor?) {
        presentationAnchor = anchor
    }
    
    private func signupWithAppleID() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
            
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func addAuthorizationObserver() {
        NotificationCenter.default.addObserver(forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
                                               object: nil,
                                               queue: nil) { notification in
            print("Received the revoked notification. \(notification)")
        }
    }
    
}

extension AppleSignViewModel: AppleSignViewModelOutputs {
    
    private func mapResult() {
        cancellable = signViewModel.output.authResult.sink { [unowned self] result in
            switch result {
            case .loginSucceeded(let model):
                self.authSubject.send(.loginSucceeded(model))
            case .failure(let error):
                self.authSubject.send(.failure(error))
            default:
                let error = NSError(domain: "apple login error", code: -10001)
                self.authSubject.send(.failure(error))
            }
        }
    }
    
}

extension AppleSignViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // 苹果用户唯一标识符，该值在同一个开发者账号下的所有 App 下是一样的，开发者可以用该唯一标识符与自己后台系统的账号体系绑定起来。
            let userId = appleIDCredential.user
            
            // 保存到 keychain
            KeychainItem.saveAppleUserIdentifier(userId)
            
            var authorizationCode: String? = nil
            if let data = appleIDCredential.authorizationCode {
                authorizationCode = String(data: data, encoding: .utf8)
            }
            var identityToken: String? = nil
            if let data = appleIDCredential.identityToken {
                identityToken = String(data: data, encoding: .utf8)
            }
            print("code: \(String(describing: authorizationCode))")
            print("token: \(String(describing: identityToken))")
            if let token = identityToken {
                signViewModel.input.apple(authorizationToken: token)
            }
            
//            // 解析
//            var authorizationCode: String? = nil
//            if let data = appleIDCredential.authorizationCode {
//                authorizationCode = String(data: data, encoding: .utf8)
//            }
//            var identityToken: String? = nil
//            if let data = appleIDCredential.identityToken {
//                identityToken = String(data: data, encoding: .utf8)
//            }
//
//            // 组装
//            var user = AppleIDCredential()
//            user.userId = userId
//            user.authorizationCode = authorizationCode   // 服务器验证需要使用的参数
//            user.identityToken = identityToken           // 服务器验证需要使用的参数
//            user.fullName = appleIDCredential.fullName   // 苹果用户信息 如果授权过，可能无法再次获取该信息
//            user.email = appleIDCredential.email         // 苹果用户信息 如果授权过，可能无法再次获取该信息
//            user.realUserStatus = appleIDCredential.realUserStatus

        case let passwordCredential as ASPasswordCredential:
            // 用户登录使用现有的密码凭证
            let user = passwordCredential.user
            let password = passwordCredential.password
            print("user: \(user)")
            print("password: \(password)")
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let err = error as? ASAuthorizationError {
            var errMsg = ""
            switch err.code {
            case .canceled:
                errMsg = "用户取消了授权请求"
            case .failed:
                errMsg = "授权请求失败"
            case .invalidResponse:
                errMsg = "授权请求响应无效"
            case .notHandled:
                errMsg = "未能处理授权请求"
            case .notInteractive:
                errMsg = "授权请求无动作"
            case .unknown:
                errMsg = "未知错误"
            @unknown default:
                break
            }
            
            print("error: \(errMsg)")
        }
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.presentationAnchor!
    }
    
}
