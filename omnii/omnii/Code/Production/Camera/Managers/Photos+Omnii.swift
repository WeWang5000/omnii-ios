//
//  Photos+Omnii.swift
//  omnii
//
//  Created by huyang on 2023/5/20.
//

import Foundation
import UIKit
import Photos

extension PHAsset {
    
    // 加载图片，生成 PhotoModel
    func loadPhotoModel(manager: PHImageManager,
                        options: PHImageRequestOptions,
                        targetSize size: CGSize,
                        contentMode mode: PHImageContentMode,
                        completion: @escaping (PhotoModel?) -> Void) {
        
        manager.requestImage(for: self,
                             targetSize: size,
                             contentMode: mode,
                             options: options) { image, info in
            
            if let info = info,
                let isDegraded = info["PHImageResultIsDegradedKey"] as? Bool,
                isDegraded == false,
                let image = image {
                
                let photo = PhotoModel(asset: self)
                photo.image = image.cropped()
                photo.location = self.location
                
                completion(photo)
                return
            }
            
            completion(nil)
        }
        
    }
    
    // 加载高清照片
    func loadImage(size: CGSize = CGSize(width: 720, height: 1280),
                   contentMode: PHImageContentMode = .aspectFit,
                   completion: @escaping (UIImage?) -> Void) {
        
        let manager = PHImageManager()

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        
        manager.requestImage(for: self, targetSize: size, contentMode: contentMode, options: options) { image, _ in
            if let image = image {
                completion(image)
            } else {
                completion(nil)
            }
        }

    }
    
    func loadThumbnail(size: CGSize = CGSize(width: 120.rpx, height: 120.rpx),
                       contentMode: PHImageContentMode = .aspectFit,
                       completion: @escaping (UIImage?) -> Void) {
        
        let manager = PHImageManager()

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        manager.requestImage(for: self,
                             targetSize: size,
                             contentMode: contentMode,
                             options: options) { image, info in
            
            if let info = info,
               let isDegraded = info["PHImageResultIsDegradedKey"] as? Bool, !isDegraded,
               let image = image {
                completion(image)
                return
            }
            
            completion(nil)
        }
        
    }
    
}

extension PHAssetCollection {
    
    // 加载相册资源，生成 PhotoCollectionModel
    func loadPhotoCollection(size: CGSize = CGSize(width: 720, height: 1280),
                             completion: @escaping (PhotoCollectionModel) -> Void) {
        
        guard let title = self.localizedTitle else { return }
                
        let assets = fetchAssets()
        
        guard assets.count > 0 else { return }
        
        let photoCollectionModel = PhotoCollectionModel(name: title)
        photoCollectionModel.count = assets.count
        
        assets.loadPhotoModels(size: size) { photoModels in
            photoCollectionModel.photos = photoModels
            let photo = photoModels.last!
            photoCollectionModel.coverAsset = photo.asset
            photoCollectionModel.coverImage = photo.image
        }
        
        completion(photoCollectionModel)
    }
    
    func fetchPhotoCollection(completion: @escaping (PhotoCollectionModel) -> Void) {
        
        guard let title = self.localizedTitle else { return }
        
        let assets = fetchAssets()

        guard assets.count > 0 else { return }
        
        let photoCollectionModel = PhotoCollectionModel(name: title)
        photoCollectionModel.count = assets.count
        
        assets.fetchPhotoModels { photoModels in
            photoCollectionModel.photos = photoModels
            let photo = photoModels.last!
            photoCollectionModel.coverAsset = photo.asset
            photoCollectionModel.coverImage = photo.image
        }
        
        completion(photoCollectionModel)
    }
    
    // 加载相册内所有资源
    func fetchAssets(mediaTypes: [PHAssetMediaType] = [.image]) -> [PHAsset] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let fetchResult = PHAsset.fetchAssets(in: self, options: options)
        
        var assets = [PHAsset]()
        fetchResult.enumerateObjects { asset, _, _ in
            if mediaTypes.contains(asset.mediaType) {
                assets.append(asset)
            }
        }

        return assets
    }
    
    // 加载所有相册
    class func fetchCollections(with type: PHAssetCollectionType) -> [PHAssetCollection] {
        let options = PHFetchOptions()
        options.includeAssetSourceTypes = [.typeUserLibrary] // typeCloudShared
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: type, subtype: .albumRegular, options: options)

        var collections = [PHAssetCollection]()
        fetchResult.enumerateObjects { collection, _, _ in
            collections.append(collection)
        }
        
        return collections
    }
    
}


extension Array where Element == PHAsset {
    
    // asset to photoModel
    // 不加载image
    func fetchPhotoModels(completion: @escaping ([PhotoModel]) -> Void) {
        var photos = [PhotoModel]()

        for asset in self {
            let photo = PhotoModel(asset: asset)
            photo.location = asset.location
            photos.append(photo)
        }
        
        completion(photos)
    }
    
    // asset to photoModel
    // 加载image
    func loadPhotoModels(size: CGSize = CGSize(width: 720, height: 1280),
                         contentMode mode: PHImageContentMode = .aspectFit,
                         completion: @escaping ([PhotoModel]) -> Void) {
        
        let manager = PHImageManager()

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        var photos = [PhotoModel]()
        
        for asset in self {
            
            asset.loadPhotoModel(manager: manager,
                                 options: options,
                                 targetSize: size,
                                 contentMode: mode) { model in
                
                if let photo = model {
                    photos.append(photo)
                }

            }
            
        }
        
        completion(photos)
    }
    
}

