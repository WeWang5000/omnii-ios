//
//  ShareAllFriendsViewModel.swift
//  omnii
//
//  Created by huyang on 2023/5/31.
//

import Foundation
import Combine
import IGListDiffKit

struct ShareAllFriendsModel {
    
    // user nickname
    let name: String
    
    // switch button state
    var isSelected: Bool = false
    
    
    func viewModel() -> AllFriendsCellModel {
        return AllFriendsCellModel(model: self)
    }
    
}


protocol ShareAllFriendsViewModelInputs {
    func selectedToggle()
}


protocol ShareAllFriendsViewModelOutputs {
    var isSelected: Bool { get }
    var selectedPublisher: AnyPublisher<Bool, Never> { get }
}


final class AllFriendsCellModel {
    
    var input: ShareAllFriendsViewModelInputs { self }
    var output: ShareAllFriendsViewModelOutputs { self }
    
    private(set) var model: ShareAllFriendsModel
    
    init(model: ShareAllFriendsModel) {
        self.model = model
        
        self.selectedPublisher = selectedSubject.eraseToAnyPublisher()
    }
    
    // subject and publisher
    private let selectedSubject = PassthroughSubject<Bool, Never>()
    let selectedPublisher: AnyPublisher<Bool, Never>
    
}

extension AllFriendsCellModel: ShareAllFriendsViewModelInputs {
    
}

extension AllFriendsCellModel: ShareAllFriendsViewModelOutputs {
    
    var isSelected: Bool {
        model.isSelected
    }
    
    func selectedToggle() {
        model.isSelected.toggle()
        selectedSubject.send(model.isSelected)
    }
    
}

extension AllFriendsCellModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return model.name as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? AllFriendsCellModel else { return false }
        return model.name == object.model.name
    }
    
}
