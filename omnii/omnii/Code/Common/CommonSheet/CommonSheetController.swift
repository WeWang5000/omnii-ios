//
//  CommonSheetController.swift
//  omnii
//
//  Created by huyang on 2023/6/16.
//

import UIKit
import IGListKit
import CommonUtils

class CommonSheetController: UIViewController {
    
    var selectedHandler: ((CommonSheetItem) -> Void)?
    
    private let cellHeight = 52.rpx

    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private var collectionView: UICollectionView!
    private var headerView: PickerHeaderView!
    
    private let items: [CommonSheetItem]
    private let sheetTitle: String?
    
    required init(items: [CommonSheetItem], title: String? = nil) {
        self.items = items
        self.sheetTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.roundCorners([.topLeft, .topRight], radius: 30.rpx)
        setupViews()
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
    }
    
    private func setupViews() {

        let bgColor = UIColor(hexString: "#151517")
        view.backgroundColor = bgColor
        
        headerView = PickerHeaderView(frame: .zero).then {
            $0.backgroundColor = bgColor
            $0.title = self.sheetTitle
            var height = 40.rpx
            if let title = self.sheetTitle, !title.isEmpty {
                height += 33.rpx
            }
            $0.frame = CGRect(origin: .zero, size: CGSize(width: ScreenWidth, height: height))
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.backgroundColor = bgColor
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.alwaysBounceHorizontal = false
            let y = headerView.frame.maxY
            let height = Double(self.items.count) * cellHeight
            $0.frame = CGRect(x: .zero, y: y, width: ScreenWidth, height: height)
        }
        
        let height = headerView.height + collectionView.height + ScreenFit.safeBottomHeight
        let y = ScreenHeight - height
        view.frame = CGRect(x: .zero, y: y, width: ScreenWidth, height: height)
        
        view.addSubview(headerView)
        view.addSubview(collectionView)
        
    }
    
}

extension CommonSheetController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return items
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? CommonSheetCell,
                  let item = item as? CommonSheetItem
            else { return }
            
            cell.bindItem(item)
        }

        let sizeBlock = { [unowned self] (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else { return .zero }
            return CGSize(width: context.containerSize.width, height: self.cellHeight)
        }
        
        let sectionController = ListSingleSectionController(cellClass: CommonSheetCell.self,
                                                            configureBlock: configureBlock,
                                                            sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        return sectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}

extension CommonSheetController: ListSingleSectionControllerDelegate {
    
    func didSelect(_ sectionController: ListSingleSectionController, with object: Any) {
        guard let item = object as? CommonSheetItem else { return }
        selectedHandler?(item)
        if item.tapDismiss { dismiss(animated: true) }
    }
    
}
