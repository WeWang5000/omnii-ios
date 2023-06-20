//
//  MoyaExtensions.swift
//  omnii
//
//  Created by huyang on 2023/4/30.
//

import Foundation
import Combine
import CombineExt
import Moya

extension AnyPublisher where Output == Response, Failure == MoyaError {
    
    // fetch body data
    func filterBody(failsOnEmptyData: Bool = true) -> AnyPublisher<Data, MoyaError> {
        return unwrapThrowable { response in
            try response.filterBody(failsOnEmptyData: failsOnEmptyData)
        }
    }
    
    // body is object, and must is not null
    @available(*, deprecated, message: "use .filterBody() and .map(D.Type)")
    func mapObject<D: Decodable>(_ type: D.Type) -> AnyPublisher<D, MoyaError> {
        return map(ObjectModel<D>.self)
            .unwrapThrowable { model in
                if model.code.count > 4 { // code 大于 4 位是错误码
                    let error = NSError(domain: model.message, code: Int(model.code) ?? 0, userInfo: [NSLocalizedDescriptionKey : model.message])
                    throw MoyaError.underlying(error, nil)
                }
                guard let body = model.body else {
                    let error = NSError(domain: "decode error", code: Int(model.code) ?? 0, userInfo: [NSLocalizedDescriptionKey : "body is null"])
                    throw MoyaError.underlying(error, nil)
                }
                return body
            }
    }
    
    // body id array
    @available(*, deprecated, message: "use .filterBody() and .map(D.Type)")
    func mapArray<D: Decodable>(_ type: D.Type) -> AnyPublisher<[D], MoyaError> {
        return map(ArrayModel<D>.self)
            .unwrapThrowable { model in
                if model.code.count > 4 { // code 大于 4 位是错误码
                    let error = NSError(domain: model.message, code: Int(model.code) ?? 0, userInfo: [NSLocalizedDescriptionKey : model.message])
                    throw MoyaError.underlying(error, nil)
                }
                return model.body
            }
    }
    
}

extension AnyPublisher where Output == Data, Failure == MoyaError {
    
    func map<D: Decodable>(_ type: D.Type) -> AnyPublisher<D, MoyaError> {
        return unwrapThrowable { data in
            try data.map(type)
        }
    }
    
    func map<D: Decodable>(_ type: [D].Type) -> AnyPublisher<[D], MoyaError> {
        return unwrapThrowable { data in
            try data.map(type)
        }
    }
    
}

extension AnyPublisher where Failure == MoyaError {
    
    func showErrorToast() -> AnyPublisher<Output, MoyaError> {
        return self.handleEvents(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                error.showToast()
            }
        })
        .eraseToAnyPublisher()
    }
    
    func catchErrorWithToast() -> AnyPublisher<Output, Never> {
        return self.handleEvents(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                error.showToast()
            }
        })
        .ignoreFailure()
        .eraseToAnyPublisher()
    }
    
    private func unwrapThrowable<T>(throwable: @escaping (Output) throws -> T) -> AnyPublisher<T, MoyaError> {
        self.tryMap { element in
            try throwable(element)
        }
        .mapError { error -> MoyaError in
            if let moyaError = error as? MoyaError {
                return moyaError
            } else {
                return .underlying(error, nil)
            }
        }
        .eraseToAnyPublisher()
    }
    
}

extension MoyaError {
    
    func showToast() {
        print("\n API failure: " + (self.errorDescription ?? "") + "\n")
        
        UIApplication.shared
            .topMostViewController()?
            .warningAlert(title: "Request Error", message: self.errorDescription ?? "")
    }
    
}


extension Response {
    
    func filterBody(failsOnEmptyData: Bool = true) throws -> Data {
        
        guard let jsonObject = try mapJSON(failsOnEmptyData: failsOnEmptyData) as? [String: Any] else {
            throw MoyaError.jsonMapping(self)
        }
        
        guard let code = jsonObject["code"] as? String else {
            let error = NSError(domain: "Filter error", code: 99999, userInfo: [NSLocalizedDescriptionKey : "response not contains code"])
            throw MoyaError.underlying(error, self)
        }
        
        var message = ""
        if let msg = jsonObject["message"] as? String {
            message = msg
        }
        
        if code.count > 4 {
            let error = NSError(domain: message, code: Int(code) ?? 0, userInfo: [NSLocalizedDescriptionKey : message])
            throw MoyaError.underlying(error, nil)
        }
        
        guard let body = jsonObject["body"] else {
            if failsOnEmptyData {
                let error = NSError(domain: "Filter error", code: Int(code) ?? 0, userInfo: [NSLocalizedDescriptionKey : "response body is null"])
                throw MoyaError.underlying(error, nil)
            }
            return Data()
        }
        
        guard JSONSerialization.isValidJSONObject(body) else {
            if failsOnEmptyData {
                let error = NSError(domain: "Filter error", code: Int(code) ?? 0, userInfo: [NSLocalizedDescriptionKey : "fail body to data, maybe body is Optional<null>"])
                throw MoyaError.underlying(error, nil)
            }
            return Data()
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw MoyaError.jsonMapping(self)
        }
        
    }
    
}

extension Data {
    
    func map<D: Decodable>(_ type: D.Type) throws -> D {
        do {
            return try JSONDecoder().decode(type, from: self)
        } catch let error {
            throw MoyaError.objectMapping(error, Response(statusCode: 99999, data: self))
        }
    }
    
    func map<D: Decodable>(_ type: [D].Type) throws -> [D] {
        do {
            return try JSONDecoder().decode(type, from: self)
        } catch let error {
            throw MoyaError.objectMapping(error, Response(statusCode: 99999, data: self))
        }
    }
    
}
