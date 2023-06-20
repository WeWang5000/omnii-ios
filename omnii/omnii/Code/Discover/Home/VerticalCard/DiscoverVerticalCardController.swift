//
//  DiscoverVerticalCardController.swift
//  omnii
//
//  Created by huyang on 2023/6/4.
//

import UIKit
import Combine
import IGListKit
import CommonUtils

final class DiscoverVerticalCardController: NSObject {
    
    var isHidden: Bool {
        get { collectionView.isHidden }
        set { collectionView.isHidden = newValue }
    }
    
    var alpha: Double {
        get { collectionView.alpha }
        set { collectionView.alpha = newValue }
    }
    
    private var adapter: ListAdapter!
    private var collectionView: UICollectionView!
   
    private lazy var emptyView: LoadingView = {
        return LoadingView(frame: UIScreen.main.bounds)
    }()
    
    private weak var viewController: DiscoverController?
    private weak var viewModel: DiscoverViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }

    required init(viewController: DiscoverController, viewModel: DiscoverViewModel) {
        self.viewController = viewController
        self.viewModel = viewModel
        super.init()
        
        setupViews()
        addObservers()
        
        adapter = ListAdapter(updater: ListAdapterUpdater(),
                              viewController: viewController,
                              workingRangeSize: 3)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
    }
    
    func performUpdates(animated: Bool, completion: ListUpdaterCompletion? = nil) {
        adapter.performUpdates(animated: animated, completion: completion)
    }
    
    private func addObservers() {
        
        viewModel?.refreshPublisher
            .sink(receiveValue: { [unowned self] style in
                self.refresh(with: style)
            })
            .store(in: &cancellables)
        
    }
    
    private func setupViews() {
                
        collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.backgroundColor = .black
            $0.alwaysBounceVertical = true
            $0.alwaysBounceHorizontal = false
            $0.showsVerticalScrollIndicator = false
            $0.contentInset = UIEdgeInsets(top: ScreenFit.omniiNavigationBarHeight + 10.rpx,
                                           left: .zero,
                                           bottom: 40.rpx,
                                           right: .zero)
        }
        
        viewController?.view.addSubview(collectionView)
    }
    
    private func refresh(with style: DiscoverRefreshStyle) {
        switch style {
        case .clear:
            self.adapter.reloadData()
        case .reloadData:
            self.adapter.reloadData { [unowned self] finished in
                self.emptyView.end()
            }
        case .update:
            self.adapter.performUpdates(animated: true) { [unowned self] finished in
                self.emptyView.end()
            }
        case .none:
            self.emptyView.end()
        }
    }
    
}

extension DiscoverVerticalCardController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let viewModel = viewModel else { return [ListDiffable]() }
        return viewModel.datasource
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return DiscoverVerticalCardSection()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        emptyView.start()
        return emptyView
    }
    
}

extension DiscoverVerticalCardController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewController?.isBrowseButtonHidden(true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        viewController?.isBrowseButtonHidden(false)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate { return }
        viewController?.isBrowseButtonHidden(false)
    }
    
}
