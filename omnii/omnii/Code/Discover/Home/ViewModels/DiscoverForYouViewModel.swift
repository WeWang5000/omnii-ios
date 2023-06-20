//
//  DiscoverForYouViewModel.swift
//  omnii
//
//  Created by huyang on 2023/6/14.
//

import Foundation
import Combine

protocol DiscoverForYouViewModelInputs {
    func request(params: [String : Any]?, more: Bool)
}

protocol DiscoverForYouViewModelOutputs {
    var dataSource: [DiscoverRecordViewModel] { get }
}

final class DiscoverForYouViewModel {
    
    var input: DiscoverForYouViewModelInputs { self }
    var output: DiscoverForYouViewModelOutputs { self }
    
    var refreshStyle: ((DiscoverRefreshStyle) -> Void)?

    // 最近一次请求结果
    private var lastModel: DiscoverModel?
    // 数据源列表
    private var items = [DiscoverRecordViewModel]()
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    init() { }
    
    private func mapToViewModel(from records: [DiscoverRecordModel]) -> [DiscoverRecordViewModel] {
        return records.map {
            let viewModel = DiscoverRecordViewModel(model: $0)
            return viewModel
        }
    }
    
}

extension DiscoverForYouViewModel: DiscoverForYouViewModelInputs {
    
    func request(params: [String : Any]?, more: Bool) {
        let page = (lastModel == nil) ? 1 : (more ? (lastModel!.current + 1) : 1)
        
        var requestParams = [
            "current" : page,
            "size"    : 10,
            "type"    : "ALL"
        ] as [String : Any]
        
        if let params = params {
            params.forEach { requestParams[$0] = $1 }
        }
        
        Provider.requestPublisher(.discoverForYou(requestParams))
            .filterSuccessfulStatusCodes()
            .filterBody()
            .map(DiscoverModel.self)
            .showErrorToast()
            .sink(receiveCompletion: { [unowned self] in
                if case .failure(_) = $0 {
                    self.refreshStyle?(.none)
                }
            }, receiveValue: { [unowned self] model in
                if !more {
                    self.items.removeAll()
                }
                self.lastModel = model
                self.items.append(contentsOf: self.mapToViewModel(from: model.records))
                if self.items.isEmpty {
                    self.refreshStyle?(.reloadData)
                } else {
                    self.refreshStyle?(.update)
                }
            })
            .store(in: &cancellables)
    }
    
}

extension DiscoverForYouViewModel: DiscoverForYouViewModelOutputs {
 
    var dataSource: [DiscoverRecordViewModel] {
        return [DiscoverRecordViewModel]()
    }
    
}
