//
//  InvitesLocationViewModel.swift
//  omnii
//
//  Created by huyang on 2023/5/27.
//

import UIKit
import Moya
import Combine
import CommonUtils
import CoreLocation

protocol InvitesLocationViewModelInputs {
    // 获取poi信息
    func requestLocations(keyword: String?)
}


protocol InvitesLocationViewModelOutputs {
    // 列表
    var items: [LocationEntity] { get }
    // poi请求回调
    var locationsResult: AnyPublisher<Bool, Never> { get }
}


final class InvitesLocationViewModel {
    
    var input: InvitesLocationViewModelInputs { self }
    var output: InvitesLocationViewModelOutputs { self }
    
    private var geoModels: [GeoModel]?
    private var _items: [LocationEntity]?
    
    // locations result publisher
    private let locationsSubject = PassthroughSubject<Bool, Never>() //temp
    let locationsResult: AnyPublisher<Bool, Never> // output
    
    // combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    init() {
        self.locationsResult = locationsSubject.eraseToAnyPublisher()
    }
    
    private func locationsPublisher(keyword: String?) -> AnyPublisher<Response, MoyaError> {
        guard let keyword = keyword else {
            let coordinate = LocationManager.shared.userCoordinate
            guard let coor = coordinate else {
                return Fail(error: MoyaError.requestMapping("cann't fetch user coordinate")).eraseToAnyPublisher()
            }
            let params = ["longitude" : coor.longitude,
                          "latitude"  : coor.latitude]
            return Provider.requestPublisher(.geoReverse(params, true))
        }
        
        let params = ["keywords" : keyword]
        return Provider.requestPublisher(.geoOldForwarding(params))
    }
    
}

extension InvitesLocationViewModel: InvitesLocationViewModelInputs {
    
    func requestLocations(keyword: String?) {
        locationsPublisher(keyword: keyword)
            .filterSuccessfulStatusCodes()
            .filterBody()
            .map([GeoModel].self)
            .catchErrorWithToast()
            .sink { [unowned self] models in
                self.geoModels = models
                self.locationsSubject.send(true)
            }
            .store(in: &cancellables)
    }
    
}

extension InvitesLocationViewModel: InvitesLocationViewModelOutputs {
    
    var items: [LocationEntity] {
        var entities = [LocationEntity]()

        guard let geoModels = geoModels else { return entities }
        
        for model in geoModels {
            
            let layout = LocationLayout().with {
                
                $0.titleSize = CGSize().with {
                    let font = UIFont(type: .montserratBlod, size: 14.rpx)!
                    let width = 335.rpx
                    $0.width = width
                    $0.height = model.name.height(font: font, containerWidth: width)
                }
                
                $0.detailSize = CGSize().with {
                    let font = UIFont(type: .montserratRegular, size: 12.rpx)!
                    let width = 335.rpx
                    $0.width = width
                    $0.height = model.description.height(font: font, containerWidth: width)
                }
                
//                $0.distanceSize = CGSize().with {
//                    let font = UIFont(type: .montserratRegular, size: 12.rpx)!
//                    let width = 40.rpx
//                    $0.width = width
//                    $0.height = distanceStr.height(font: font, containerWidth: width)
//                }
                
                $0.height = $0.topPadding + $0.titleSize.height + $0.middlePadding + $0.detailSize.height + $0.bottomPadding
                
            }
            
            entities.append(LocationEntity(model: model, layout: layout))
        }
        
        return entities
    }
    
}
    
