//
//  DiscoverSearchLocationResultViewModel.swift
//  omnii
//
//  Created by huyang on 2023/6/18.
//

import Foundation
import Combine

protocol DiscoverSearchLocationResultViewModelInputs {
    func switchSecondaryKey(to key: DiscoverSearchLocationResultViewModel.SecondaryKey)
}

final class DiscoverSearchLocationResultViewModel {
    
    var input: DiscoverSearchLocationResultViewModelInputs { self }
    
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
    
    private let nearbyViewModel = DiscoverNearbyViewModel()
    
    // create publisher
    private let refreshSubject = PassthroughSubject<DiscoverRefreshStyle, Never>()
    let refreshPublisher: AnyPublisher<DiscoverRefreshStyle, Never>
    
    private(set) var secondaryKey = SecondaryKey.all
    
    init() {
        refreshPublisher = refreshSubject.eraseToAnyPublisher()
        
        nearbyViewModel.refreshStyle = { [unowned self] style in
            self.refreshSubject.send(style)
        }
    }
    
}

extension DiscoverSearchLocationResultViewModel: DiscoverSearchLocationResultViewModelInputs {
    
    func request(params: [String : Any]?, more: Bool) {
        nearbyViewModel.input.request(params: params, more: more)
    }
    
    func switchSecondaryKey(to key: DiscoverSearchLocationResultViewModel.SecondaryKey) {
        self.secondaryKey = key
        self.refreshSubject.send(.update)
    }
    
}

extension DiscoverSearchLocationResultViewModel: DiscoverViewModel {
    
    var datasource: [DiscoverRecordViewModel] {
        return nearbyViewModel.dataSource
    }
    
}
