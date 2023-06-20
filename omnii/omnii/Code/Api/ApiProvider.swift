//
//  ApiProvider.swift
//  omnii
//
//  Created by huyang on 2023/4/30.
//

import Foundation
import Moya

//private let endPointClosure = { (target: Api) -> Endpoint in
//    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: MultiTarget(target))
//    
//    switch defaultEndpoint.task {
//    case .requestParameters(var params, let encoding):
//        params["lng"] = "EN"
//        return Endpoint(url: defaultEndpoint.url, sampleResponseClosure: defaultEndpoint.sampleResponseClosure, method: defaultEndpoint.method, task: .requestParameters(parameters: params, encoding: encoding), httpHeaderFields: defaultEndpoint.httpHeaderFields)
//    default:
//        break
//    }
//    
//    return defaultEndpoint
//}
//
//
//let provider = MoyaProvider<Api>(endpointClosure: endPointClosure)

let Provider = MoyaProvider<Api>(plugins: [LoadingPlugin()])


