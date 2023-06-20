//
//  MomentsLocationSection.swift
//  omnii
//
//  Created by huyang on 2023/5/16.
//

import UIKit
import IGListKit

protocol MomentsLocationSectionDelegate: AnyObject {
    func didSelect(_ sectionController: MomentsLocationSection, with object: GeoModel)
}

final class MomentsLocationSection: ListSectionController {
    
    weak var delegate: MomentsLocationSectionDelegate?
    
    private var item: MomentsLocationModel!
    
    required init(delegate: MomentsLocationSectionDelegate? = nil) {
        self.delegate = delegate
        super.init()
        
        supplementaryViewSource = self
    }
    
    override func numberOfItems() -> Int {
        return item.locations.count
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 52.rpx)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: MomentsLocationCell = collectionContext?.dequeueReusableCell(of: MomentsLocationCell.self, for: self, at: index) as! MomentsLocationCell
        cell.title = item.locations[index].name
        return cell
    }

    override func didUpdate(to object: Any) {
        super.didUpdate(to: object)
        item = object as? MomentsLocationModel
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        
        let geo = item.locations[index]
        delegate?.didSelect(self, with: geo)
        
        self.viewController?.dismiss(animated: true)
    }

}

extension MomentsLocationSection: ListSupplementaryViewSource {
    
    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return locationHeaderView(at: index)
        case UICollectionView.elementKindSectionFooter:
            return UICollectionReusableView()
        default:
            fatalError()
        }
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        if isFirstSection {
            return .zero
        }
        return CGSize(width: collectionContext!.containerSize.width, height: 36.rpx)
    }
    
    private func locationHeaderView(at index: Int) -> UICollectionReusableView {
        let view: MomentsLocationHeader = collectionContext?.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            for: self,
            class: MomentsLocationHeader.self,
            at: index) as! MomentsLocationHeader
        view.name = isFirstSection ? "" : "Nearby location"
        return view
    }

}
