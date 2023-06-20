//
//  DiscoverHomeViewModel.swift
//  omnii
//
//  Created by huyang on 2023/6/12.
//

import UIKit
import Combine
import CoreLocation

protocol DiscoverHomeViewModelInputs {
    func switchPrimaryKey(to key: DiscoverHomeViewModel.PrimaryKey)
    func switchSecondaryKey(to key: DiscoverHomeViewModel.SecondaryKey)
    func updateCoordinate(coordinate: CLLocationCoordinate2D)
}

final class DiscoverHomeViewModel {
    
    var input: DiscoverHomeViewModelInputs { self }
    var output: DiscoverViewModel { self }
    
    private let nearbyViewModel = DiscoverNearbyViewModel()
    private let friendsViewModel = DiscoverFriendsViewModel()
    private let foryouViewModel = DiscoverFriendsViewModel()

    // 主选键
    enum PrimaryKey: String, CaseIterable {
        case friends = "Friends"
        case forYou  = "For You"
        case nearby  = "Nearby"
        
        static var allRaws: [String] {
            var raws = [String]()
            for ca in allCases {
                raws.append(ca.rawValue)
            }
            return raws
        }
    }
    
    // 副选键
    enum SecondaryKey: String, CaseIterable {
        case all      = "All"
        case moments  = "Moments"
        case invites  = "Invites"
        
        static var allRaws: [String] {
            var raws = [String]()
            for ca in allCases {
                raws.append(ca.rawValue)
            }
            return raws
        }
    }
    
    private(set) var primaryKey = PrimaryKey.nearby
    private(set) var secondaryKey = SecondaryKey.all
    
    // create publisher
    private let refreshSubject = PassthroughSubject<DiscoverRefreshStyle, Never>()
    let refreshPublisher: AnyPublisher<DiscoverRefreshStyle, Never>
    
    init() {
        
        refreshPublisher = refreshSubject.eraseToAnyPublisher()
        
        nearbyViewModel.refreshStyle = { [unowned self] style in
            self.refreshSubject.send(style)
        }
        
        friendsViewModel.refreshStyle = { [unowned self] style in
            self.refreshSubject.send(style)
        }
        
        foryouViewModel.refreshStyle = { [unowned self] style in
            self.refreshSubject.send(style)
        }
        
    }
    
    private func requestSecondaryType() -> String {
        switch secondaryKey {
        case .all:
            return "ALL"
        case .moments:
            return "MOMENT"
        case .invites:
            return "INVITE"
        }
    }
    
}

extension DiscoverHomeViewModel: DiscoverHomeViewModelInputs {
    
    func request(params: [String : Any]?, more: Bool) {
        switch primaryKey {
        case .nearby:
            nearbyViewModel.input.request(params: params, more: more)
        case .friends:
            friendsViewModel.input.request(params: params, more: more)
        case .forYou:
            foryouViewModel.input.request(params: params, more: more)
        }
    }
    
    func switchPrimaryKey(to key: PrimaryKey) {
        self.primaryKey = key
        switch key {
        case .nearby:
            guard nearbyViewModel.dataSource.isEmpty else {
                self.refreshSubject.send(.update)
                return
            }
            self.refreshSubject.send(.clear)
            nearbyViewModel.input.request(params: nil, more: false)
        case .friends:
            guard friendsViewModel.dataSource.isEmpty else {
                self.refreshSubject.send(.update)
                return
            }
            self.refreshSubject.send(.clear)
            friendsViewModel.input.request(params: nil, more: false)
        case .forYou:
            guard foryouViewModel.dataSource.isEmpty else {
                self.refreshSubject.send(.update)
                return
            }
            self.refreshSubject.send(.clear)
            foryouViewModel.input.request(params: nil, more: false)
        }
    }
    
    func switchSecondaryKey(to key: SecondaryKey) {
        self.secondaryKey = key
        self.refreshSubject.send(.update)
    }
    
    func updateCoordinate(coordinate: CLLocationCoordinate2D) {
        if primaryKey == .nearby {
            nearbyViewModel.updateCoordinate(coordinate: coordinate)
        }
    }
    
}

extension DiscoverHomeViewModel: DiscoverViewModel {
    
    var datasource: [DiscoverRecordViewModel] {
        switch primaryKey {
        case .nearby:
            return nearbyViewModel.dataSource
        case .friends:
            return friendsViewModel.dataSource
        case .forYou:
            return foryouViewModel.dataSource
        }
    }
    
}
