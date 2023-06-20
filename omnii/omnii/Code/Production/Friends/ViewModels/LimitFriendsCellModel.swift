//
//  ShareLimitFriendsViewModel.swift
//  omnii
//
//  Created by huyang on 2023/5/31.
//

import Foundation
import Combine
import IGListDiffKit
import SwifterSwift

protocol ShareLimitFriendsViewModelInputs {
    
    func addFriend(_ model: FriendModel)
    func removeFriend(_ model: FriendModel)
    func clear()
}


protocol ShareLimitFriendsViewModelOutputs {
    
    var friends: [FriendModel] { get }
    
    var updateFriendsPublisher: AnyPublisher<[FriendModel], Never> { get }
    
}


final class LimitFriendsCellModel {
    
    var input: ShareLimitFriendsViewModelInputs { self }
    var output: ShareLimitFriendsViewModelOutputs { self }
    
    private var _friends: [FriendModel] = [FriendModel]()
    
    init() {
        updateFriendsPublisher = updateFriendsSubject.eraseToAnyPublisher()
    }
    
    // subject and publisher
    private let updateFriendsSubject = PassthroughSubject<[FriendModel], Never>()
    let updateFriendsPublisher: AnyPublisher<[FriendModel], Never>
    
}

extension LimitFriendsCellModel: ShareLimitFriendsViewModelInputs {
    
    func addFriend(_ model: FriendModel) {
        if _friends.contains(model) { return }
        _friends.append(model)
        updateFriendsSubject.send(_friends)
    }
    
    func removeFriend(_ model: FriendModel) {
        guard _friends.contains(model) else { return }
        _friends.removeAll(model)
        updateFriendsSubject.send(_friends)
    }
    
    func clear() {
        _friends.removeAll()
        updateFriendsSubject.send(_friends)
    }
    
}

extension LimitFriendsCellModel: ShareLimitFriendsViewModelOutputs {
    
    var friends: [FriendModel] {
        return _friends
    }
    
}

extension LimitFriendsCellModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return "Limit" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
    
}
