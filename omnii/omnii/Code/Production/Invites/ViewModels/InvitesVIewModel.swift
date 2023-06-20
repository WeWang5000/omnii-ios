//
//  InvitesVIewModel.swift
//  omnii
//
//  Created by huyang on 2023/6/8.
//

import Foundation
import Combine

protocol InvitesViewModelInputs {
    
    func updateLocation(_ geo: GeoModel)
    func updateContent(_ content: String)
    func updateLimitNum(_ limit: Int)
    func updateDate(_ date: Date)
    func updateUserIds(_ friends: [String])
    func updateShareType(_ type: InvitesViewModel.ShareScopeType)
    
    func requestInvites()
    
}


protocol InvitesViewModelOutputs {
    var createIvitesResult: AnyPublisher<Bool, Never> { get }
    var warningAlertResult: AnyPublisher<String, Never> { get }
    
    var inviteData: InvitesViewModel.DataSource { get }
}

final class InvitesViewModel {
    
    enum ShareScopeType: String {
        case everyone = "EVERYONE"
        case friend = "FRIEND"
        case `private` = "ONLYME"
    }
    
    struct DataSource {
        var longitude: Double?
        var latitude: Double?
        var address: String?
        var content: String?
        var name: String?
        var type: String?
        var description: String?
        var appointedTime: String?
        var selectUserIds: [String]?
        var limitNum: Int = 0
        var shareScopeType: String = "EVERYONE"
    }
    
    var input: InvitesViewModelInputs { self }
    var output: InvitesViewModelOutputs { self }
    
    // invites 数据源
    private var dataSource = DataSource()
    
    // 创建 invites
    private let createIvitesSubject = PassthroughSubject<Bool, Never>()
    let createIvitesResult: AnyPublisher<Bool, Never>
    
    // 警告弹窗
    private let warningAlertSubject = PassthroughSubject<String, Never>()
    var warningAlertResult: AnyPublisher<String, Never>
    
    // combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    init() {
        self.createIvitesResult = createIvitesSubject.eraseToAnyPublisher()
        self.warningAlertResult = warningAlertSubject.eraseToAnyPublisher()
    }
    
}

extension InvitesViewModel: InvitesViewModelInputs {
    
    func updateLocation(_ geo: GeoModel) {
        dataSource.type = geo.type
        dataSource.name = geo.name
        dataSource.address = geo.address
        dataSource.description = geo.description
        dataSource.latitude = geo.latitude
        dataSource.longitude = geo.longitude
    }
    
    func updateContent(_ content: String) {
        dataSource.content = content
    }
    
    func updateLimitNum(_ limit: Int) {
        dataSource.limitNum = limit
    }
    
    func updateDate(_ date: Date) {
        dataSource.appointedTime = date.string(withFormat: "yyyy-MM-dd HH:mm:ss")
    }
    
    func updateUserIds(_ friends: [String]) {
        dataSource.limitNum = friends.count
        dataSource.selectUserIds = friends
    }
    
    func updateShareType(_ type: InvitesViewModel.ShareScopeType) {
        dataSource.shareScopeType = type.rawValue
    }
    
    func requestInvites() {
        
        if dataSource.shareScopeType == ShareScopeType.friend.rawValue {
            guard let selectUserIds = dataSource.selectUserIds, !selectUserIds.isEmpty else {
                warningAlertSubject.send("must invite at least one friend")
                return
            }
        }
        
        var params: [String: Any] = ["shareScopeType" : dataSource.shareScopeType,
                                     "limitNum" : dataSource.limitNum]
        
        if let appointedTime = dataSource.appointedTime {
            params["appointedTime"] = appointedTime
        }
        
        if let address = dataSource.address {
            params["address"] = address
        }
        
        if let name = dataSource.name {
            params["name"] = name
        }
        
        if let description = dataSource.description {
            params["description"] = description
        }
        
        if let type = dataSource.type {
            params["type"] = type
        }
        
        if let latitude = dataSource.latitude {
            params["latitude"] = latitude
        }
        
        if let longitude = dataSource.longitude {
            params["longitude"] = longitude
        }
        
        if let content = dataSource.content {
            params["content"] = content
        }
        
        if let selectUserIds = dataSource.selectUserIds {
            params["selectUserIds"] = selectUserIds
        }
        
        Provider.requestPublisher(.createInvites(params))
            .filterSuccessfulStatusCodes()
            .filterBody(failsOnEmptyData: false)
            .catchErrorWithToast()
            .sink(receiveValue: { [unowned self] _ in
                self.createIvitesSubject.send(true)
            })
            .store(in: &cancellables)
        
    }
}

extension InvitesViewModel: InvitesViewModelOutputs {
    
    var inviteData: DataSource {
        return dataSource
    }
    
}
