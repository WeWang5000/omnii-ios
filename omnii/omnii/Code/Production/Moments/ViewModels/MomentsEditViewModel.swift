//
//  MomentsEditViewModel.swift
//  omnii
//
//  Created by huyang on 2023/5/16.
//


import UIKit
import Photos
import Combine
import Moya

protocol MomentsEditViewModelInputs {
    
    func setPhotoModel(_ photo: PhotoModel)
        
    // 检索坐标附近poi
    func requestGeoReverse(with photo: PhotoModel?, showHud: Bool)
        
    // moments 数据源更新操作
    func updateContent(_ content: String?)
    func updateLocation(_ geo: GeoModel?)
    func updateImageURL(_ url: String?)
    func updateSelectedFriends(_ friends: [FriendModel]?)
    func updateShareType(_ type: MomentsEditViewModel.ShareScopeType)
    
    // 发布moments
    func requestShareMoments()
}


protocol MomentsEditViewModelOutputs {
    // 图片回调
    var imageResult: AnyPublisher<UIImage, Never> { get }
    // poi 信息回调
    var locationsResult: AnyPublisher<[MomentsLocationModel], Never> { get }
    // create moments 回调
    var createMomentsResult: AnyPublisher<Bool, Never> { get }
    // poi 信息
    var locations: [MomentsLocationModel]? { get }
    // moments 信息
    var momentsSource: MomentsEditViewModel.DataSource { get }
    
}


final class MomentsEditViewModel {
    
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
        var imageUrl: String?
        var allowUserIds: [String]?
        var shareScopeType: String = "EVERYONE"
    }
    
    
    
    var input: MomentsEditViewModelInputs { self }
    var output: MomentsEditViewModelOutputs { self }
    
    // moments 数据源
    private var dataSource = DataSource()
    
    // 获取高清图片
    private let assetManager = AssetManager()
    
    // poi位置信息
    private var locationsModels: [MomentsLocationModel]?
    
    // 图片资源
    private var photo: PhotoModel?
    
    // 高清图片 combine publisher
    private let imageSubject = PassthroughSubject<UIImage, Never>() //temp
    let imageResult: AnyPublisher<UIImage, Never> // output
    
    // poi 信息 combine publisher
    private let locationsSubject = PassthroughSubject<[MomentsLocationModel], Never>()
    let locationsResult: AnyPublisher<[MomentsLocationModel], Never>
    
    // 创建moments
    private let createMomentsSubject = PassthroughSubject<Bool, Never>()
    let createMomentsResult: AnyPublisher<Bool, Never>

    // combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    init() {
        self.imageResult = imageSubject.eraseToAnyPublisher()
        self.locationsResult = locationsSubject.eraseToAnyPublisher()
        self.createMomentsResult = createMomentsSubject.eraseToAnyPublisher()
    }
    
    private func fetchHighImage(photo: PhotoModel) {
        DispatchQueue.global().async {
            photo.loadHighImage { image in
                guard let image = image else { return }
                self.imageSubject.send(image)
            }
        }
    }
    
    private func createLocations(items: [GeoModel], showHud: Bool) {
        var item1 = [GeoModel]()
        var item2 = [GeoModel]()
        for (index, model) in items.enumerated() {
            if index == 0 {
                item1.append(model)
            } else {
                item2.append(model)
            }
        }
        let location1 = MomentsLocationModel(locations: item1)
        let location2 = MomentsLocationModel(locations: item2)
        locationsModels = [location1, location2]
        
        // 默认定位信息
        input.updateLocation(item1.first)
        
        if showHud {
            self.locationsSubject.send(locationsModels!)
        }
    }
    
    // poi 检索
    private func requestGeoReverse(with coordinate: CLLocationCoordinate2D?, showHud: Bool) {
        guard let coor = coordinate else { return }
        
        let params = ["longitude" : coor.longitude,
                      "latitude"  : coor.latitude]
        Provider.requestPublisher(.geoReverse(params, showHud))
            .filterSuccessfulStatusCodes()
            .filterBody()
            .map([GeoModel].self)
            .catchErrorWithToast()
            .sink(receiveValue: { [unowned self] models in
                self.createLocations(items: models, showHud: showHud)
            })
            .store(in: &cancellables)
    }
    
    // 预先请求 s3 链接
    private func presigned() {
        let fileName = UUID().uuidString
        let params = ["fileName" : fileName,
                      "contentType" : "image/jpeg"]
        Provider.requestPublisher(.presigned(params))
            .filterSuccessfulStatusCodes()
            .mapString(atKeyPath: "body")
            .catchErrorWithToast()
            .sink { [unowned self] url in
                self.input.updateImageURL(fileName)
                self.upload(url: url)
            }
            .store(in: &cancellables)
    }
    
    // 上传资源
    private func upload(url: String) {
        guard let photo = self.photo else { return }
        let data = photo.image!.jpegData(compressionQuality: 1.0)
        guard let data = data else { return }
        Provider.requestPublisher(.upload(data, url))
            .filterSuccessfulStatusCodes()
            .catchErrorWithToast()
            .sink { [unowned self] _ in
                self.shareMoments()
            }
            .store(in: &cancellables)
    }
    
    private func shareMoments() {
        var params: [String: Any] = ["shareScopeType" : dataSource.shareScopeType,
                                     "content" : ""]
        
        if let imageUrl = dataSource.imageUrl {
            params["imageUrl"] = imageUrl
        }
        
        if let address = dataSource.address {
            params["address"] = address
        }
        
        if let latitude = dataSource.latitude {
            params["latitude"] = latitude
        }
        
        if let longitude = dataSource.longitude {
            params["longitude"] = longitude
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
        
        if let content = dataSource.content {
            params["content"] = content
        }
        
        if let allowUserIds = dataSource.allowUserIds {
            params["allowUserIds"] = allowUserIds
        }
        
        Provider.requestPublisher(.createMoments(params))
            .filterSuccessfulStatusCodes()
            .filterBody(failsOnEmptyData: false)
            .catchErrorWithToast()
            .sink(receiveValue: { [unowned self] _ in
                self.createMomentsSubject.send(true)
            })
            .store(in: &cancellables)
    }
    
}

extension MomentsEditViewModel: MomentsEditViewModelInputs {
    
    func setPhotoModel(_ photo: PhotoModel) {
        self.photo = photo
        requestGeoReverse(with: photo, showHud: false)
        
        fetchHighImage(photo: photo)
    }
    
    func requestGeoReverse(with photo: PhotoModel?, showHud: Bool) {
        var coordinate: CLLocationCoordinate2D?
        if let location = photo?.location {
            coordinate = location.coordinate
        } else {
            coordinate = LocationManager.shared.userCoordinate
        }
        
        requestGeoReverse(with: coordinate, showHud: showHud)
    }
    
    func updateContent(_ content: String?) {
        self.dataSource.content = content
    }
    
    func updateLocation(_ geo: GeoModel?) {
        self.dataSource.name = geo?.name
        self.dataSource.type = geo?.type
        self.dataSource.address = geo?.address
        self.dataSource.latitude = geo?.latitude
        self.dataSource.longitude = geo?.longitude
        self.dataSource.description = geo?.description
    }
    
    func updateImageURL(_ url: String?) {
        self.dataSource.imageUrl = url
    }
    
    func updateSelectedFriends(_ friends: [FriendModel]?) {
        if let friends = friends, !friends.isEmpty {
            self.dataSource.allowUserIds = friends.map { $0.userId }
        } else {
            self.dataSource.allowUserIds = nil
        }
    }
    
    func updateShareType(_ type: ShareScopeType) {
        self.dataSource.shareScopeType = type.rawValue
    }
    
    func requestShareMoments() {
        guard let _ = self.photo else {
            shareMoments() // 只有文本
            return
        }
        
        // 包含资源上传
        presigned()
    }
    
}

extension MomentsEditViewModel: MomentsEditViewModelOutputs {
    
    var locations: [MomentsLocationModel]? {
        return locationsModels
    }
    
    var momentsSource: DataSource {
        return dataSource
    }
    
}
