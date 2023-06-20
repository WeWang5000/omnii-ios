//
//  AuthRequest.swift
//  omnii
//
//  Created by huyang on 2023/4/30.
//

import Foundation
import Combine
import Moya


final class AuthRequest {
    
    enum SignCustomType: String {
        case mobile = "mobile"
        case apple  = "apple"
    }
    
    func captcha(prefix: String, phone: String) -> AnyPublisher<Response, MoyaError> {
        let params = [
            "prefix": prefix,
            "mobile": phone
        ]
        return Provider.requestPublisher(.captcha(params))
    }
    
    func login(code: String, security: String) -> AnyPublisher<Response, MoyaError> {
        let params = [
            "verifyCode": code,
            "securityCode": security
        ]
        return Provider.requestPublisher(.login(params))
    }
        
    func supplement(nickname: String, birthday: String, gender: String) -> AnyPublisher<Response, MoyaError> {
        let params = ["nickname" : nickname,
                      "birthday" : birthday,
                      "gender" : gender]
        return Provider.requestPublisher(.supplement(params))
    }
    
    func apple(authorizationToken token: String) -> AnyPublisher<Response, MoyaError> {
        let params = ["authorizationType" : "apple",
                      "authorizationToken" : token]
        return Provider.requestPublisher(.apple(params))
    }
    
}
