//
//  DiscoverViewModel.swift
//  omnii
//
//  Created by huyang on 2023/6/18.
//

import Foundation
import Combine

protocol DiscoverViewModel: AnyObject {
    
    func request(params: [String: Any]?, more: Bool)
    
    var refreshPublisher: AnyPublisher<DiscoverRefreshStyle, Never> { get }
    
    var datasource: [DiscoverRecordViewModel] { get }
    
}

// discover collection 刷新类型
enum DiscoverRefreshStyle {
    case clear
    case reloadData
    case update
    case none
}
