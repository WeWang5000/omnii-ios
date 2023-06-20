//
//  PhotoGridSectionController.swift
//  omnii
//
//  Created by huyang on 2023/5/9.
//

import UIKit
import CommonUtils
import IGListKit

protocol PhotoGridSectionControllerDelegate: AnyObject {
    func didSelect(_ sectionController: PhotoGridSectionController, with object: PhotoModel)
}

final class PhotoGridSectionController: ListSectionController {
    
    weak var delegate: PhotoGridSectionControllerDelegate?
    
    private let margin = 5.0
    private let spacing = 4.0
    
    private var object: PhotoCollectionModel?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        self.minimumInteritemSpacing = spacing
        self.minimumLineSpacing = spacing
    }

    override func numberOfItems() -> Int {
        return object?.photos?.count ?? 0
    }

    override func sizeForItem(at index: Int) -> CGSize {
        guard let _ = collectionContext else { return CGSize() }
        let width = (ScreenWidth - margin * 2 - spacing * 2) / 3.0
        let height = width * 16.0 / 9.0
        return CGSize(width: width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCell(of: AblumPhotoCell.self, for: self, at: index) as! AblumPhotoCell
        
        if let object = object, let photos = object.photos {
            let photo = photos[index]
            cell.bindModel(photo)
        } else {
            cell.clear()
        }
        
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? PhotoCollectionModel
        // 滚动到底
        if let context = collectionContext {
            let index = numberOfItems() == 0 ? 0 : numberOfItems() - 1
            DispatchQueue.main.async {
                context.scroll(to: self, at: index, scrollPosition: .bottom, animated: false)
            }
        }
    }

    override func canMoveItem(at index: Int) -> Bool {
        return false
    }
    
    override func didSelectItem(at index: Int) {
        guard let delegate = delegate else { return }
        guard let object = object, let photos = object.photos else { return }

        let photo = photos[index]
        delegate.didSelect(self, with: photo)
    }
    
}
