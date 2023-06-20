//
//  CountryPickerViewController.swift
//  omnii
//
//  Created by huyang on 2023/4/23.
//

import UIKit
import CommonUtils
import IGListKit
import IGListDiffKit

class CountryPickerViewController: UIViewController {
    
    var pickResult: ((CountryItem) -> Void)?
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    lazy var countryData: [CountryItem] = {
        guard let url = Bundle.main.url(forResource: "CountryCodes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([CountryItem].self, from: data) else {
            return [CountryItem]()
        }
        return items
    }()
    
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let headerView = PickerHeaderView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.title = "Area code"
        headerView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 73.rpx)
        
        let x = 16.rpx
        let y = headerView.height
        let width = view.width - x * 2
        let height = view.height - y - 62.rpx
        collectionView.frame = CGRect(x: x, y: y, width: width, height: height)
        collectionView.backgroundColor = .black
        collectionView.cornerRadius = 12.rpx
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        view.addSubview(collectionView)
        view.addSubview(headerView)
    }
    
}

extension CountryPickerViewController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return countryData
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? CountryCodeCell, let model = item as? CountryItem else { return }
            cell.image = UIImage(named: model.code, in: Bundle.main, with: nil)
            cell.name = model.name
            cell.code = model.dialCode
        }

        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else { return CGSize() }
            return CGSize(width: context.containerSize.width, height: 51.rpx)
        }
        
        let sectionController = ListSingleSectionController(cellClass: CountryCodeCell.self,
                                                            configureBlock: configureBlock,
                                                            sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        return sectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}

extension CountryPickerViewController: ListSingleSectionControllerDelegate {
    
    func didSelect(_ sectionController: ListSingleSectionController, with object: Any) {
        guard let item = object as? CountryItem else { return }
        if let handler = pickResult { handler(item) }
    }
    
}
