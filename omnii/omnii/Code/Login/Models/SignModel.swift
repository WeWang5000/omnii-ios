//
//  SignModel.swift
//  omnii
//
//  Created by huyang on 2023/5/1.
//

import Foundation
import CommonUtils

//struct SignupModel: Decodable {
//
//    struct State: RawRepresentable, Decodable, DefaultValue {
//        static let existed = State(rawValue: "UsernameExistsException")
//
//        let rawValue: String
//
//        static var defaultValue: State { .init(rawValue: "") }
//    }
//
//    @Default.False var userConfirmed: Bool
//    @Default.Empty var userSub: String
//    @Default.Self var type: State
//    @Default.Empty var message: String
//
//    enum CodingKeys: String, CodingKey {
//        case userConfirmed  = "UserConfirmed"
//        case userSub        = "UserSub"
//        case type           = "__type"
//        case message
//    }
//
//}


struct SigninModel: Decodable {
    
    let securityCode: String
    
}

struct AuthModel: Codable {
    
    let idToken: String
    let sub: String
    let userId: String
    
    @Default.Empty var prefix: String
    @Default.Empty var mobile: String
    @Default.Empty var nickname: String
    @Default.Empty var birthday: String
    @Default.Empty var gender:String
    
}
