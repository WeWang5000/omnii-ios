//
//  BaseModel.swift
//  omnii
//
//  Created by huyang on 2023/6/5.
//

import Foundation

struct ObjectModel<D: Decodable>: Decodable {
    
    let code: String
    let message: String
    let body: D?
    
    enum CodingKeys: CodingKey {
        case code
        case message
        case body
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.message = try values.decodeIfPresent(String.self, forKey: .message) ?? ""
        self.body = try values.decodeIfPresent(D.self, forKey: .body) ?? nil
    }
    
}

struct ArrayModel<D: Decodable>: Decodable {
    
    let code: String
    let message: String
    let body: [D]
    
    enum CodingKeys: CodingKey {
        case code
        case message
        case body
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        self.message = try values.decodeIfPresent(String.self, forKey: .message) ?? ""
        self.body = try values.decodeIfPresent([D].self, forKey: .body) ?? .init()
    }
    
}
