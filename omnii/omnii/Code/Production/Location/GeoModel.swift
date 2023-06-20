//
//  GeoModel.swift
//  omnii
//
//  Created by huyang on 2023/6/5.
//

import Foundation
import CommonUtils
import IGListDiffKit

final class GeoModel: Decodable, ListDiffable {
    
    let name: String
    let type: String
    let description: String
    
    @Default.Zero var longitude: Double
    @Default.Zero var latitude: Double
    
    @Default.Empty var address: String
    @Default.Empty var addressId: String
    
    func diffIdentifier() -> NSObjectProtocol {
        return description as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? GeoModel else { return false }
        return longitude.isEqual(to: object.longitude) && latitude.isEqual(to: object.latitude)
    }
    
}
