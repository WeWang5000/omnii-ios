//
//  PhotoModel.swift
//  omnii
//
//  Created by huyang on 2023/5/9.
//

import Foundation
import Photos
import IGListDiffKit

final class PhotoCollectionModel: ListDiffable {
    
    let name: String
    var count: Int = 0
    var coverImage: UIImage?
    var coverAsset: PHAsset?
    var photos: [PhotoModel]?
    
    init(name: String) {
        self.name = name
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return name as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? PhotoCollectionModel else { return false }
        return name == object.name && count == object.count
    }
    
    func loadThumbnail(completion: @escaping (UIImage?) -> Void) {
        if let image = coverImage {
            completion(image)
        } else if let asset = coverAsset {
            asset.loadThumbnail { [unowned self] image in
                self.coverImage = image
                completion(image)
            }
        }
    }
    
}


final class PhotoModel: ListDiffable {
    
    var asset: PHAsset
    var image: UIImage?
    var thumbnail : UIImage?
    var location: CLLocation?
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return asset as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? PhotoModel else { return false }
        return asset == object.asset
    }
    
    func loadThumbnail(size: CGSize, completion: @escaping (UIImage?) -> Void) {
        if let image = thumbnail {
            completion(image)
        } else {
            asset.loadThumbnail(size: size) { [unowned self] image in
                self.thumbnail = image
                completion(image)
            }
        }
    }
    
    func loadHighImage(completion: @escaping (UIImage?) -> Void) {
        if let image = image {
            completion(image)
        } else {
            asset.loadImage { [unowned self] image in
                self.image = image
                completion(image)
            }
        }
    }
    
}
