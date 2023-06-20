//
//  MomentsLocationPicker.swift
//  omnii
//
//  Created by huyang on 2023/5/16.
//

import UIKit
import IGListKit

class MomentsLocationPicker: UIViewController {
    
    var selectHandler: ((GeoModel) -> Void)?
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let headerView = PickerHeaderView(frame: .zero)
    
    private var items: [MomentsLocationModel]
    
    required init(items: [MomentsLocationModel]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.title = "Where are you?"
        view.addSubview(headerView)
        
        let bgColor = UIColor(hexString: "#151517")
        view.backgroundColor = bgColor
        collectionView.backgroundColor = bgColor
        view.addSubview(collectionView)
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let h = 73.rpx
        headerView.frame = CGRect(x: .zero, y: .zero, width: view.width, height: h)
        collectionView.frame = CGRect(x: .zero, y: h, width: view.width, height: view.height - h)
    }
    
}

extension MomentsLocationPicker: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return items
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return MomentsLocationSection(delegate: self)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}

extension MomentsLocationPicker: MomentsLocationSectionDelegate {
    
    func didSelect(_ sectionController: MomentsLocationSection, with object: GeoModel) {
        selectHandler?(object)
    }
    
}
