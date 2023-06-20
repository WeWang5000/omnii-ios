//
//  AssetManager.swift
//  omnii
//
//  Created by huyang on 2023/5/9.
//

import UIKit
import Foundation
import Photos

final class AssetManager {
    
    let semaphore = DispatchSemaphore(value: 1)
    
    // 异步加载所有相册, 只获取asset, 不加载image
    func asyncFetchPhotoCollection(completion: @escaping ([PhotoCollectionModel]) -> Void) {
        DispatchQueue.global().async {
            self.semaphore.wait()
            self.fetchPhotoCollection { model in
                DispatchQueue.main.async {
                    completion(model)
                    self.semaphore.signal()
                }
            }
        }
    }
    
    // 加载所有相册信息
    func fetchPhotoCollection(completion: @escaping ([PhotoCollectionModel]) -> Void) {
        
        var photoCollectionModels = [PhotoCollectionModel]()
        
        // 遍历加载所有相册数据
        let map: ((PHAssetCollection) -> Void) = { collection in
            collection.fetchPhotoCollection { model in
                photoCollectionModels.append(model)
            }
        }
        
        // 系统所有相册
        PHAssetCollection.fetchCollections(with: .smartAlbum).forEach(map)
        // 自定义所有相册
        PHAssetCollection.fetchCollections(with: .album).forEach(map)
        
        completion(photoCollectionModels)
    }
    
    
    // 异步加载所有相册信息, 获取asset, 加载image
    func asyncLoadPhotoCollection(completion: @escaping ([PhotoCollectionModel]) -> Void) {
        DispatchQueue.global().async {
            self.semaphore.wait()
            self.loadPhotoCollection { model in
                DispatchQueue.main.async {
                    completion(model)
                    self.semaphore.signal()
                }
            }
        }
    }
    
    // 加载所有相册信息
    func loadPhotoCollection(completion: @escaping ([PhotoCollectionModel]) -> Void) {
        
        var photoCollectionModels = [PhotoCollectionModel]()
        
        // 遍历加载所有相册数据
        let map: ((PHAssetCollection) -> Void) = { collection in
            collection.loadPhotoCollection(size: CGSize(width: 180, height: 320)) { model in
                photoCollectionModels.append(model)
            }
        }
        
        // 系统所有相册
        PHAssetCollection.fetchCollections(with: .smartAlbum).forEach(map)
        // 自定义所有相册
        PHAssetCollection.fetchCollections(with: .album).forEach(map)
        
        completion(photoCollectionModels)
    }

}
