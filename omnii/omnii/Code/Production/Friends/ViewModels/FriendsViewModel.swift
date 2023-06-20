//
//  ShareViewModel.swift
//  omnii
//
//  Created by huyang on 2023/5/31.
//

import Foundation
import Combine
import IGListDiffKit
import Moya

protocol ShareViewModelInputs {
    // 选中状态取反
    func selectedToggle(for viewModel: SingleFriendCellModel)
    // 取消所有选中的friends
    func clear()
    // 全选
    func selectAll()
    // 请求朋友列表
    func requestFriends() -> AnyPublisher<Bool, Never>
}


protocol ShareViewModelOutputs {
    
    var items: [ListDiffable] { get }
    func items(with keyword: String?) -> [ListDiffable]
    
    var selectedFriends: [FriendModel] { get }
    
}


final class FriendsViewModel {
    
    var input: ShareViewModelInputs { self }
    var output: ShareViewModelOutputs { self }
    
    private var _items: [ListDiffable]?
    private var _allFriendViewModels: [SingleFriendCellModel]?
    private var _selectedFriendViewModels = [SingleFriendCellModel]()
    private var _friends: [FriendModel]?
    
    private let style: ShareStyle
    
    // request friends publisher
    private var friendsPublisher: AnyPublisher<FriendsListModel, MoyaError>?
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }

    init(style: ShareStyle) {
        self.style = style
    }
    
    
    private lazy var limitFriendsViewModel: LimitFriendsCellModel = {
       return LimitFriendsCellModel()
    }()
    
    private lazy var allFriendsViewModel: AllFriendsCellModel = {
        return ShareAllFriendsModel(name: "All Friends").viewModel()
    }()
    
    private func setAllFriends(selected: Bool) {
        _allFriendViewModels?.forEach {
            if $0.isSelected != selected { $0.selectedToggle() }
        }
    }
    
    private func addLimitFriend(_ model: FriendModel) {
        guard style == .invites else { return }
        limitFriendsViewModel.addFriend(model)
    }
    
    private func removeLimitFriend(_ model: FriendModel) {
        guard style == .invites else { return }
        limitFriendsViewModel.removeFriend(model)
    }
    
    private func checkAllFriends() {
        guard let viewModels = _allFriendViewModels else { return }
        if viewModels.filter({ !$0.isSelected }).count > 0 {
            if allFriendsViewModel.isSelected { allFriendsViewModel.selectedToggle() }
        } else {
            if !allFriendsViewModel.isSelected { allFriendsViewModel.selectedToggle() }
        }
    }
    
}

extension FriendsViewModel: ShareViewModelInputs {
    
    func selectedToggle(for viewModel: SingleFriendCellModel) {
        viewModel.selectedToggle()
        if viewModel.isSelected {
            if _selectedFriendViewModels.contains(viewModel) { return }
            _selectedFriendViewModels.append(viewModel)
            self.addLimitFriend(viewModel.model)
        } else {
            guard _selectedFriendViewModels.contains(viewModel) else { return }
            _selectedFriendViewModels.removeAll(viewModel)
            self.removeLimitFriend(viewModel.model)
        }
        checkAllFriends()
    }
    
    func clear() {
        if style == .invites {
            limitFriendsViewModel.clear()
        }
        _selectedFriendViewModels.removeAll()
        if allFriendsViewModel.isSelected { allFriendsViewModel.selectedToggle() }
        setAllFriends(selected: false)
    }
    
    func selectAll() {
        setAllFriends(selected: true)
        if let all = _allFriendViewModels { _selectedFriendViewModels = all }
    }
    
    func requestFriends() -> AnyPublisher<Bool, Never> {
        let subject = PassthroughSubject<Bool, Never>()
        
        let params = ["current": 1, "size": 10000]
        Provider.requestPublisher(.friendList(params))
            .filterSuccessfulStatusCodes()
            .filterBody()
            .map(FriendsListModel.self)
            .showErrorToast()
            .sink(receiveCompletion: { _ in
                subject.send(false)
            }, receiveValue: { [unowned self] listModel in
                self._friends = listModel.records
                subject.send(true)
            })
            .store(in: &cancellables)
        
        return subject.eraseToAnyPublisher()
    }
    
}

extension FriendsViewModel: ShareViewModelOutputs {
    
    var selectedFriends: [FriendModel] {
        _selectedFriendViewModels.map { $0.model }
    }
    
    var items: [ListDiffable] {
        if let items = _items { return items }
        
        guard let friends = _friends, !friends.isEmpty else { return [SingleFriendCellModel]() }
        _allFriendViewModels = friends.map { SingleFriendCellModel(model: $0) }.sorted()
        
        switch style {
        case .moments:
            _items = [allFriendsViewModel,
                      "Select Friends" as ListDiffable]
        case .invites:
            _items = [limitFriendsViewModel,
                      "Select Friends" as ListDiffable]
        }
        
        if let friends = _allFriendViewModels {
            _items!.append(contentsOf: friends)
        }
        
        return _items!
    }
    
    func items(with keyword: String?) -> [ListDiffable] {
        guard let text = keyword, text != "" else {
            return sortedItems()
        }
        return sortedItems().filter({ item in
            guard let viewModel = item as? SingleFriendCellModel else {
                return false
            }
            
            if viewModel.model.userNickName.lowercased().contains(text.lowercased()) ||
                viewModel.model.userId.lowercased().contains(text.lowercased()) {
                return true
            }
            
            return false
        })
    }
    
    private func sortedItems() -> [ListDiffable] {
        
        var sortedItems = [ListDiffable]()
        
        if items.isEmpty { return sortedItems }
        
        var selectedItems = [SingleFriendCellModel]()
        var normalItems = [SingleFriendCellModel]()
        
        items.forEach {
            
            if let friend = $0 as? SingleFriendCellModel {
                
                if friend.isSelected {
                    selectedItems.append(friend)
                } else {
                    normalItems.append(friend)
                }
                
            } else {
                sortedItems.append($0)
            }
            
        }
        
        sortedItems.append(contentsOf: selectedItems)
        sortedItems.append(contentsOf: normalItems)
        
        return sortedItems
    }
    
}
