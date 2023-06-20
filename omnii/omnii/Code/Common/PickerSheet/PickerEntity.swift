//
//  PickerEntity.swift
//  omnii
//
//  Created by huyang on 2023/5/29.
//

import Foundation

struct PickerEntity {
    
    var title: String
    var subTitle: String?
    var isPicked: Bool = false
    var tapDismiss: Bool = false
    
    func viewModel() -> PickerViewModel {
        return PickerViewModel(entity: self)
    }
    
}
