//
//  Api.swift
//  omnii
//
//  Created by huyang on 2023/4/30.
//

import Foundation
import Moya
import CoreLocation

typealias Params = [String: Any]

enum Api {
    // login
    case captcha(Params)
    case login(Params)
    case supplement(Params)
    case apple(Params)
    
    // geo server
    case geoSuggest(Params)         // 根据关键字检索地址
    case geoReverse(Params, Bool)   // 根据当前坐标检索附近的地址
    case geoRetrieve(Params)        // 根据地址id检索地址详细信息
    case geoOldForwarding(Params)   // 正向地理搜索（旧）
    case geoOldReversing(Params)    // 逆向地理搜索（旧）
    
    // aws s3
    case presigned(Params)
    case upload(Data, String)   // (image data, put url)
    
    // friends
    case friendList(Params)
    case userSearch(Params)
    
    // moments
    case createMoments(Params)
    case momentLike(Params)
    case momentDisLike(Params)
    
    // invites
    case createInvites(Params)
    case inviteJoin(Params)
    
    // discover
    case discoverNearby(Params)
    case discoverFriends(Params)
    case discoverForYou(Params)
}

extension Api: TargetType {
    
    var baseURL: URL {
        switch self {
        case let .upload(_, urlString):
            return URL(string: urlString) ?? URL(string: "")!
        default:
            return URL(string: "https://qas-api.omnii.social")!
        }
    }
    
    var path: String {
        switch self {
        case .captcha(_):
            return "/user/captcha/verify"
        case .login(_):
            return "/user/captcha/login"
        case .supplement(_):
            return "/user/basic/supplement"
        case .apple(_):
            return "/user/authorization/login"
        case .geoSuggest(_):
            return "/geo/suggest"
        case .geoReverse(_, _):
            return "/geo/reverse"
        case .geoRetrieve(_):
            return "/geo/retrieve"
        case .geoOldReversing(_):
            return "/geo/common/reversing"
        case .geoOldForwarding(_):
            return "/geo/common/forwarding"
        case .presigned(_):
            return "/presigned-url"
        case .upload(_, _):
            return ""
        case .friendList(_):
            return "/user/firend/list"
        case .userSearch(_):
            return "/user/firend/all.search"
        case .createMoments(_):
            return "/moment/create"
        case .momentLike(_):
            return "/moment/like/activate"
        case .momentDisLike(_):
            return "/moment/like/deactivate"
        case .createInvites(_):
            return "/invite/create"
        case .inviteJoin(_):
            return "/invite/join"
        case .discoverNearby(_):
            return "/interaction/discover/nearby/query"
        case .discoverFriends(_):
            return "/interaction/discover/friends/query"
        case .discoverForYou(_):
            return "/interaction/discover/foryou/query"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .upload(_, _):
            return .put
            
        case .geoReverse(_, _),
             .geoSuggest(_),
             .geoRetrieve(_),
             .geoOldReversing(_),
             .geoOldForwarding(_),
             .discoverNearby(_),
             .discoverFriends(_),
             .discoverForYou(_):
            return .get
            
        default:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case let .captcha(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .login(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .supplement(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .apple(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .geoSuggest(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .geoReverse(params, _):
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .geoRetrieve(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .geoOldReversing(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .geoOldForwarding(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .presigned(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .upload(data, _):
            return .requestData(data)
        case let .friendList(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .userSearch(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .createMoments(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .momentLike(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .momentDisLike(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .createInvites(params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .inviteJoin(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .discoverNearby(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .discoverFriends(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .discoverForYou(params):
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        if case .upload(_, _) = self {
            return ["Content-Type" : "image/jpeg"]
        }
        
        var map = ["equipment" : "ios"]
        if let token = Auth.token, !token.isEmpty {
            map["idToken"] = token
        }
        if let sub = Auth.sub, !sub.isEmpty {
            map["sub"] = sub
        }
        return map
    }
    
    var useDefaultHUD: Bool {
        switch self {
        case .discoverNearby(_),
             .discoverFriends(_),
             .discoverForYou(_),
             .geoSuggest(_),
             .userSearch(_):
            return false
            
        case let .geoReverse(_, hud):
            return hud
        
        default:
            return true
        }
        
    }
    
}

