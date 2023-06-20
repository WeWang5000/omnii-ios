//
//  DiscoverSearchUserController.swift
//  omnii
//
//  Created by huyang on 2023/6/17.
//

import UIKit
import Combine
import IGListKit
import CommonUtils

class DiscoverSearchUserController: UIViewController {
    
    static let cellHeight = 70.rpx
    
    var keyword: String? {
        didSet {
            guard isVisible else { return }
            requestSearchUserIfNeeded()
        }
    }

    private let viewModel = DiscoverSearchUserViewModel()
    private let keyboard = KeyboardManager()
    
    private var adapter: ListAdapter!
    private var collectionView: UICollectionView!
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        setupViews()
        addObserves()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard.registerMonitor()
        requestSearchUserIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboard.unregisterMonitor()
    }
    
    private func setupViews() {
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.backgroundColor = .black
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.alwaysBounceHorizontal = false
            let y = ScreenFit.statusBarHeight + 52.rpx + 58.rpx + 1.0
            $0.frame = CGRect(origin: .zero, size: CGSize(width: ScreenWidth, height: ScreenHeight - y))
        }
        
        adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self).then {
            $0.collectionView = collectionView
            $0.dataSource = self
        }
        
        view.addSubview(collectionView)
    }
    
    private func addObserves() {
        
        keyboard.action = { [unowned self] event in
            switch event {
            case .willShow(let info):
                let height = info.endFrame.height
                UIView.animate(withDuration: info.duration, delay: .zero, options: .curveEaseIn) {
                    self.collectionView.height = self.view.height - height
                }
            case .willHide(let info):
                UIView.animate(withDuration: info.duration) {
                    self.collectionView.height = self.view.height
                }
            default:
                break
            }
        }
        
        viewModel.output
            .reloadPublisher
            .sink(receiveValue: { [unowned self] in
                self.adapter.performUpdates(animated: true)
            })
            .store(in: &cancellables)
        
    }

    private func requestSearchUserIfNeeded() {
        guard isVisible else { return }
        viewModel.input.requestUserSearch(keyword: keyword)
    }

}

extension DiscoverSearchUserController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let items = viewModel.output.dataSource else { return [ListDiffable]() }
        return items
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? DiscoverSearchUserCell,
                  let item = item as? DiscoverSearchSingleUserViewModel
            else { return }
            
            cell.bindViewModel(item)
        }
        
        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else { return .zero }
            return CGSize(width: context.containerSize.width, height: DiscoverSearchUserController.cellHeight)
        }
        
        let sectionController = ListSingleSectionController(cellClass: DiscoverSearchUserCell.self,
                                                            configureBlock: configureBlock,
                                                            sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        return sectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}

extension DiscoverSearchUserController: ListSingleSectionControllerDelegate {
    
    func didSelect(_ sectionController: ListSingleSectionController, with object: Any) {
        guard let item = object as? DiscoverSearchSingleUserViewModel else { return }
        print(item)
    }
    
}
