//
//  MomentsLocationModel.swift
//  omnii
//
//  Created by huyang on 2023/5/16.
//

import Foundation
import IGListDiffKit

final class MomentsLocationModel: ListDiffable {
    
    let locations: [GeoModel]
    
    init(locations: [GeoModel]) {
        self.locations = locations
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return locations as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let _ = object as? MomentsLocationModel else { return false }
        return true
    }
    
}
