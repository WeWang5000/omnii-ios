//
//  DiscoverSearchLocationViewModel.swift
//  omnii
//
//  Created by huyang on 2023/6/17.
//

import Foundation
import Combine

protocol DiscoverSearchLocationViewModelInputs {
    func requestGeoSuggest(keyword: String?)
    func requestGeoRetrieve(addressId: String?)
}

protocol DiscoverSearchLocationViewModelOutputs {
    var reloadPublisher: AnyPublisher<Void, Never> { get }
    var retrievePublisher: AnyPublisher<GeoModel, Never> { get }
    var dataSource: [GeoModel]? { get }
}

final class DiscoverSearchLocationViewModel {
    
    var input: DiscoverSearchLocationViewModelInputs { self }
    var output: DiscoverSearchLocationViewModelOutputs { self }
    
    private var items: [GeoModel]?
    
    // create reload data publisher
    private let reloadSubject = PassthroughSubject<Void, Never>()
    let reloadPublisher: AnyPublisher<Void, Never>
    
    // create geo retrieve publisher
    private let retrieveSubject = PassthroughSubject<GeoModel, Never>()
    let retrievePublisher: AnyPublisher<GeoModel, Never>
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    init() {
        reloadPublisher = reloadSubject.eraseToAnyPublisher()
        retrievePublisher = retrieveSubject.eraseToAnyPublisher()
    }
    
}

extension DiscoverSearchLocationViewModel: DiscoverSearchLocationViewModelInputs {
    
    func requestGeoSuggest(keyword: String?) {
        guard let keyword = keyword, !keyword.isEmpty else {
            self.items?.removeAll()
            self.reloadSubject.send()
            return
        }
        
        let params = ["keywords" : keyword]
        Provider.requestPublisher(.geoSuggest(params))
            .filterSuccessfulStatusCodes()
            .filterBody()
            .map([GeoModel].self)
            .catchErrorWithToast()
            .sink { [unowned self] models in
                self.items = models
                self.reloadSubject.send()
            }
            .store(in: &cancellables)
    }
    
    func requestGeoRetrieve(addressId: String?) {
        guard let id = addressId else { return }
        
        let params = ["addressId" : id]
        Provider.requestPublisher(.geoRetrieve(params))
            .filterSuccessfulStatusCodes()
            .filterBody()
            .map(GeoModel.self)
            .catchErrorWithToast()
            .sink { [unowned self] model in
                self.retrieveSubject.send(model)
            }
            .store(in: &cancellables)
    }
    
}

extension DiscoverSearchLocationViewModel: DiscoverSearchLocationViewModelOutputs {
    
    var dataSource: [GeoModel]? {
        return items
    }
    
}
