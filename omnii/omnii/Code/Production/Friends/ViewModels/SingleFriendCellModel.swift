//
//  ShareFriendViewModel.swift
//  omnii
//
//  Created by huyang on 2023/5/30.
//

import Foundation
import Combine
import IGListDiffKit

protocol ShareFriendViewModelInputs {

    func selectedToggle()

}


protocol ShareFriendViewModelOutputs {
        
    var isSelected: Bool { get }
    
    var selectedPublisher: AnyPublisher<Bool, Never> { get }

}

final class SingleFriendCellModel {
    
    var input: ShareFriendViewModelInputs { self }
    var output: ShareFriendViewModelOutputs { self }
    
    private(set) var model: FriendModel
    private var _isSelected: Bool = false
    
    init(model: FriendModel) {
        self.model = model
        
        self.selectedPublisher = selectedSubject.eraseToAnyPublisher()
    }
    
    // subject and publisher
    private let selectedSubject = PassthroughSubject<Bool, Never>()
    let selectedPublisher: AnyPublisher<Bool, Never>
    
}

extension SingleFriendCellModel: ShareFriendViewModelInputs {
    
    func selectedToggle() {
        _isSelected.toggle()
        selectedSubject.send(_isSelected)
    }
    
}

extension SingleFriendCellModel: ShareFriendViewModelOutputs {
    
    var isSelected: Bool {
        return _isSelected
    }
    
}

extension SingleFriendCellModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return model.userId as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? SingleFriendCellModel else { return false }
        return model.userId == object.model.userId
    }
    
}

extension SingleFriendCellModel: Comparable {
    
    static func < (lhs: SingleFriendCellModel, rhs: SingleFriendCellModel) -> Bool {
        return lhs.model.userNickName < rhs.model.userNickName
    }
    
    static func == (lhs: SingleFriendCellModel, rhs: SingleFriendCellModel) -> Bool {
        return lhs.model.userId == rhs.model.userId
    }
    
}
