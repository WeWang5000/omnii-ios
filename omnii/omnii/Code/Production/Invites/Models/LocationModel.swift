//
//  LocationModel.swift
//  omnii
//
//  Created by huyang on 2023/5/27.
//

import Foundation
import CommonUtils
import IGListDiffKit


struct LocationLayout {
    
    var titleSize: CGSize = .zero
    var detailSize: CGSize = .zero
    var distanceSize: CGSize = .zero
    
    var height: Double = .zero
    var topPadding: Double = 12.rpx
    var middlePadding: Double = 5.rpx
    var bottomPadding: Double = 12.rpx
    
}

extension LocationLayout: Then {}


final class LocationEntity: NSObject, ListDiffable {
    
    let model: GeoModel
    let layout: LocationLayout
    
    func diffIdentifier() -> NSObjectProtocol {
        return model.diffIdentifier()
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? LocationEntity else { return false }
        return model.isEqual(toDiffableObject: object.model)
    }
    
    init(model: GeoModel, layout: LocationLayout) {
        self.model = model
        self.layout = layout
    }
    
}
