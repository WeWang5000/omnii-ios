//
//  PickerViewModel.swift
//  omnii
//
//  Created by huyang on 2023/5/30.
//

import Foundation
import Combine
import IGListDiffKit

protocol PickerViewModelInputs {
    
    func setPicked(_ picked: Bool)
    
}


protocol PickerViewModelOutputs {
    
    var pickPublisher: AnyPublisher<Bool, Never> { get }
    
}

final class PickerViewModel {
    
    var input: PickerViewModelInputs { self }
    var output: PickerViewModelOutputs { self }
    
    // subject and publisher
    private let pickSubject = PassthroughSubject<Bool, Never>()
    let pickPublisher: AnyPublisher<Bool, Never>
    
    var entity: PickerEntity!
    
    init(entity: PickerEntity) {
        self.entity = entity
        
        self.pickPublisher = pickSubject.eraseToAnyPublisher()
    }
    
}

extension PickerViewModel: PickerViewModelInputs {
    
    func setPicked(_ picked: Bool) {
        entity.isPicked = picked
        pickSubject.send(picked)
    }
    
}

extension PickerViewModel: PickerViewModelOutputs {
    
}


extension PickerViewModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return entity.title as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? PickerViewModel else { return false }
        return entity.title == object.entity.title &&
                entity.subTitle == object.entity.subTitle &&
                entity.isPicked == object.entity.isPicked
    }
    
}
