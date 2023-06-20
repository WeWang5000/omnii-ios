//
//  CommonSheetItem.swift
//  omnii
//
//  Created by huyang on 2023/6/16.
//

import Foundation
import IGListDiffKit

final class CommonSheetItem {
    
    let title: String
    let icon: UIImage
    let tapDismiss: Bool
    
    init(title: String, icon: UIImage, tapDismiss: Bool = false) {
        self.title = title
        self.icon = icon
        self.tapDismiss = tapDismiss
    }
    
}

extension CommonSheetItem: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return title as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let _ = object as? CommonSheetItem else { return false }
        return true
    }
    
}
