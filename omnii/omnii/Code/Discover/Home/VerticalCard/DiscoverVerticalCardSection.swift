//
//  DiscoverVerticalCardSection.swift
//  omnii
//
//  Created by huyang on 2023/6/4.
//

import UIKit
import IGListKit

final class DiscoverVerticalCardSection: ListSectionController {
    
    typealias Cell = DiscoverVerticalCardCell

    private var viewModel: DiscoverRecordViewModel?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
    
    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: 355.rpx, height: 631.rpx)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let viewModel = viewModel,
              let context = collectionContext,
              let viewController = viewController as? DiscoverController
        else { return UICollectionViewCell() }
        
        if viewModel.model.interactionType == .invite {
            let cell = context.dequeueReusableCell(of: Cell<DiscoverInviteCardView>.self, for: self, at: index)
            if let cell = cell as? Cell<DiscoverInviteCardView> {
                cell.tapHandler = viewModel.tapHandler(controller: viewController)
                cell.bindViewModel(viewModel)
            }
            return cell
        }
        
        if viewModel.model.interactionType == .moment {
            
            // 纯文本
            if viewModel.model.imageUrl.isEmpty {
                let cell = context.dequeueReusableCell(of: Cell<DiscoverMindCardView>.self, for: self, at: index)
                if let cell = cell as? Cell<DiscoverMindCardView> {
                    cell.tapHandler = viewModel.tapHandler(controller: viewController)
                    cell.bindViewModel(viewModel)
                }
                return cell
            }
            
            // 带图片
            let cell = context.dequeueReusableCell(of: Cell<DiscoverImageCardView>.self, for: self, at: index)
            if let cell = cell as? Cell<DiscoverImageCardView> {
                cell.tapHandler = viewModel.tapHandler(controller: viewController)
                cell.bindViewModel(viewModel)
            }
            return cell
        }
        
        return UICollectionViewCell()
    }

    override func didUpdate(to object: Any) {
        viewModel = object as? DiscoverRecordViewModel
    }
    
    override func didSelectItem(at index: Int) {
        guard let context = collectionContext else { return }
        context.scroll(to: self, at: index, scrollPosition: .centeredHorizontally, animated: true)
    }

}
