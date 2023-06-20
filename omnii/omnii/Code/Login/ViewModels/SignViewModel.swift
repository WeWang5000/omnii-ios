//
//  SignViewModel.swift
//  omnii
//
//  Created by huyang on 2023/4/26.
//

import Foundation
import Moya
import Combine
import CombineExt
import CommonUtils

enum SigninResult {
    case captchaSucceeded
    case captchaFailure(Error)
    case loginSucceeded(AuthModel)
    case supplementSucceeded
    case failure(Error)
}


protocol SignViewModelInputs {
    // 请求验证码
    func captcha(prefix: String, phone: String)
    // 登录&确认验证码
    func login(code: String)
    // 注册登录.基础信息.补充完善
    func supplement(nickname: String, birthday: String, gender: String)
    // 注册登录.身份提供商.授权登录
    func apple(authorizationToken: String)
}


protocol SignViewModelOutputs {
    // 授权流程回调
    var authResult: AnyPublisher<SigninResult, Never> { get }
}


final class SignViewModel {
    
    var input: SignViewModelInputs { self }
    var output: SignViewModelOutputs { self }
    
    private let request = AuthRequest()
    private var signinResult: SigninModel?
    
    private var captchaCancellable: AnyCancellable?
    private var loginCancellable: AnyCancellable?
    private var nicknameCancellable: AnyCancellable?
    private var supplementCancellable: AnyCancellable?
    private var appleCancellable: AnyCancellable?

    private let authSubject = PassthroughSubject<SigninResult, Never>()
    let authResult: AnyPublisher<SigninResult, Never>
    
    init() {
        self.authResult = authSubject.eraseToAnyPublisher()
    }

}


extension SignViewModel: SignViewModelInputs {
    
    func captcha(prefix: String, phone: String) {
        captchaCancellable = request.captcha(prefix: prefix, phone: phone)
            .filterSuccessfulStatusCodes()
            .filterBody()
            .map(SigninModel.self)
            .showErrorToast()
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 {
                    self.authSubject.send(.captchaFailure(error))
                }
            }, receiveValue: { [unowned self] response in
                self.signinResult = response
                self.authSubject.send(.captchaSucceeded)
            })
    }

    
    func login(code: String) {
        guard let response = signinResult else { return }
        loginCancellable = request.login(code: code, security: response.securityCode)
            .filterSuccessfulStatusCodes()
            .filterBody()
            .map(AuthModel.self)
            .showErrorToast()
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 {
                    self.authSubject.send(.failure(error))
                }
            }, receiveValue: { [unowned self] model in
                KeychainItem.saveUserIdentifier(model.userId)
                Auth.update(model)
                ChatManager.connectSendbirdChat()
                self.authSubject.send(.loginSucceeded(model))
            })
    }
    
    func supplement(nickname: String, birthday: String, gender: String) {
        supplementCancellable = request.supplement(nickname: nickname, birthday: birthday, gender: gender)
            .filterSuccessfulStatusCodes()
            .filterBody(failsOnEmptyData: false)
            .showErrorToast()
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 {
                    self.authSubject.send(.failure(error))
                }
            }, receiveValue: { _ in
                if var user = Auth.user {
                    user.birthday = birthday
                    user.gender = gender
                    Auth.update(user)
                }
                self.authSubject.send(.supplementSucceeded)
            })
    }
    
    func apple(authorizationToken: String) {
        appleCancellable = request.apple(authorizationToken: authorizationToken)
            .filterSuccessfulStatusCodes()
            .filterBody()
            .map(AuthModel.self)
            .showErrorToast()
            .sink(receiveCompletion: {
                if case .failure(let error) = $0 {
                    self.authSubject.send(.failure(error))
                }
            }, receiveValue: { [unowned self] model in
                KeychainItem.saveUserIdentifier(model.userId)
                Auth.update(model)
                self.authSubject.send(.loginSucceeded(model))
            })
    }
    
}

extension SignViewModel: SignViewModelOutputs {
    
}
