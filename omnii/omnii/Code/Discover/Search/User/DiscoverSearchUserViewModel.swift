//
//  DiscoverSearchUserViewModel.swift
//  omnii
//
//  Created by huyang on 2023/6/17.
//

import Foundation
import Combine
import IGListDiffKit

protocol DiscoverSearchUserViewModelInputs {
    func requestUserSearch(keyword: String?)
}

protocol DiscoverSearchUserViewModelOutputs {
    var reloadPublisher: AnyPublisher<Void, Never> { get }
    var dataSource: [DiscoverSearchSingleUserViewModel]? { get }
}

final class DiscoverSearchUserViewModel {
    
    var input: DiscoverSearchUserViewModelInputs { self }
    var output: DiscoverSearchUserViewModelOutputs { self }
    
    private var items: [DiscoverSearchSingleUserViewModel]?
    
    // create publisher
    private let reloadSubject = PassthroughSubject<Void, Never>()
    let reloadPublisher: AnyPublisher<Void, Never>
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    init() {
        reloadPublisher = reloadSubject.eraseToAnyPublisher()
    }
    
    
    
}

extension DiscoverSearchUserViewModel: DiscoverSearchUserViewModelInputs {
    
    func requestUserSearch(keyword: String?) {
        guard let keyword = keyword, !keyword.isEmpty else {
            self.items?.removeAll()
            self.reloadSubject.send()
            return
        }
        
        let params = [
            "condition" : keyword.lowercased(),
            "current" : 1,
            "size" : 20
        ] as [String : Any]
        Provider.requestPublisher(.userSearch(params))
            .filterSuccessfulStatusCodes()
            .filterBody()
            .map(FriendsListModel.self)
            .catchErrorWithToast()
            .sink { [unowned self] model in
                self.items = model.records.map { return DiscoverSearchSingleUserViewModel(model: $0) }
                self.reloadSubject.send()
            }
            .store(in: &cancellables)
    }
    
}

extension DiscoverSearchUserViewModel: DiscoverSearchUserViewModelOutputs {
    
    var dataSource: [DiscoverSearchSingleUserViewModel]? {
        return items
    }
    
}


final class DiscoverSearchSingleUserViewModel: ListDiffable {
    
    private(set) var model: FriendModel
    
    init(model: FriendModel) {
        self.model = model
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return model.userId as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? DiscoverSearchSingleUserViewModel else { return false }
        return model.userId == object.model.userId
    }
    
}
