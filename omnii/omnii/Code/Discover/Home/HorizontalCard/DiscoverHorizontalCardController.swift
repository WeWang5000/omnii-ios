//
//  DiscoverMapCardListAdapter.swift
//  omnii
//
//  Created by huyang on 2023/6/2.
//

import UIKit
import Combine
import IGListKit
import CommonUtils


final class DiscoverHorizontalCardController: NSObject {
    
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
                switch style {
                case .reloadData:
                    self.adapter.reloadData()
                case .update:
                    self.adapter.performUpdates(animated: true)
                default:
                    break
                }
            })
            .store(in: &cancellables)
        
    }
    
    private func setupViews() {
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: DiscoverCardFlowLayout()).then {
            $0.backgroundColor = .clear
            $0.decelerationRate = .fast
            $0.alwaysBounceVertical = false
            $0.alwaysBounceHorizontal = true
            $0.showsHorizontalScrollIndicator = false
            let size = CGSize(width: ScreenWidth, height: 340.rpx)
            let y = ScreenHeight - ScreenFit.safeBottomHeight - 60.rpx - size.height
            $0.frame = CGRect(x: .zero, y: y, size: size)
        }
        
        viewController?.view.addSubview(collectionView)
    }
    
}

extension DiscoverHorizontalCardController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let viewModel = viewModel
        else { return [ListDiffable]() }
        
        return viewModel.datasource
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return DiscoverHorizontalCardSection()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}

extension DiscoverHorizontalCardController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let initialOffset = (collectionView.bounds.size.width - layout.itemSize.width) / 2
        let currentItemCentralX =
            collectionView.contentOffset.x + initialOffset + layout.itemSize.width / 2
        let pageWidth = layout.itemSize.width + layout.minimumLineSpacing
        let index = Int(currentItemCentralX / pageWidth)
        print(index)
    }
    
}
