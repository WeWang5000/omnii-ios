//
//  PickerSheetController.swift
//  omnii
//
//  Created by huyang on 2023/5/29.
//

import UIKit
import IGListKit
import CommonUtils

final class PickerSheetController: UIViewController {
    
    enum State {
        case select(PickerEntity)
        case confirm(PickerEntity)
    }
    
    typealias handler = ((State) -> Void)
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let headerView = PickerHeaderView(frame: .zero)
    private let confirmButton = UIButton(type: .custom)
    
    private var selectedViewModel: PickerViewModel?
    
    private let pickTitle: String
    private let buttonTitle: String
    private let viewModels: [PickerViewModel]
    private let confirmDismiss: Bool
    private let actionHandler: handler?
    
    required init(items: [PickerEntity], title: String, buttonTitle: String, confirmDismiss: Bool = false, actionHandler: handler? = nil) {
        self.pickTitle = title
        self.buttonTitle = buttonTitle
        self.viewModels = items.map { $0.viewModel() }
        self.confirmDismiss = confirmDismiss
        self.actionHandler = actionHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.frame = CGRect(x: .zero, y: .zero, width: view.width, height: 71.rpx)
        
        confirmButton.do {
            let size = $0.size
            let x = (view.width - size.width) / 2.0
            let y = view.height - ScreenFit.safeBottomHeight - size.height
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        collectionView.do {
            let x = 0.0
            let y = self.headerView.frame.maxY
            let width = view.width
            let height = self.confirmButton.y - 10.rpx - y
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
    }
    
    private func setupViews() {
        
        headerView.title = pickTitle
        
        let bgColor = UIColor(hexString: "#151517")
        view.backgroundColor = bgColor
        collectionView.backgroundColor = bgColor
        
        confirmButton.size = CGSize(width: 320.rpx, height: 55.rpx)
        confirmButton.whiteBackgroundStyle(title: buttonTitle)
        confirmButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubview(headerView)
        view.addSubview(collectionView)
        view.addSubview(confirmButton)
    }
    
    @objc private func click(_ sender: UIButton) {
        if let viewModel = selectedViewModel {
            actionHandler?(.confirm(viewModel.entity))
            if confirmDismiss { dismiss(animated: true) }
        }
    }
    
}

extension PickerSheetController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return viewModels
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return sectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    private func sectionController() -> ListSectionController {
        let configureBlock = { [unowned self] (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? PickerSheetCell,
                  let viewModel = item as? PickerViewModel
            else { return }
            
            cell.setViewModel(viewModel)
            
            if viewModel.entity.isPicked {
                self.selectedViewModel = viewModel
                self.actionHandler?(.select(viewModel.entity))
            }
        }

        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else { return .zero }
            return CGSize(width: context.containerSize.width, height: 52.rpx)
        }
        
        let sectionController = ListSingleSectionController(cellClass: PickerSheetCell.self,
                                                            configureBlock: configureBlock,
                                                            sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        return sectionController
    }
    
}

extension PickerSheetController: ListSingleSectionControllerDelegate {
    
    func didSelect(_ sectionController: ListSingleSectionController, with object: Any) {
        selectedViewModel?.input.setPicked(false)
        guard let viewModel = object as? PickerViewModel else { return }
        viewModel.input.setPicked(true)
        selectedViewModel = viewModel
        actionHandler?(.select(viewModel.entity))
        if viewModel.entity.tapDismiss { dismiss(animated: true) }
    }
    
}
