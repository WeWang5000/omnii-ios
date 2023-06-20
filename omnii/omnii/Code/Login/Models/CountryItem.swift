//
//  CountryModel.swift
//  omnii
//
//  Created by huyang on 2023/4/23.
//

import Foundation
import IGListDiffKit

final class CountryItem: Codable {
    
    let name: String
    let dialCode: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case dialCode = "dial_code"
        case code
    }
    
}


extension CountryItem: ListDiffable {
 
    func diffIdentifier() -> NSObjectProtocol {
        return name as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? CountryItem else { return false }
        return name == object.name && dialCode == object.dialCode && code == object.code
    }
    
}
