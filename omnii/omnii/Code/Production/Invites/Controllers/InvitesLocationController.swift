//
//  InvitesLocationController.swift
//  omnii
//
//  Created by huyang on 2023/5/27.
//

import UIKit
import Combine
import CommonUtils
import IGListKit

class InvitesLocationController: UIViewController {
    
    var popHandler: ((Date, GeoModel) -> Void)?
    
    var selectedHandler: ((GeoModel) -> Void)?
    
    private var navigationBar: NavigationBar!
    private var searchBar: SearchBar!
    private var collectionView: UICollectionView!
    private var progressView1: UIView!
    private var progressView2: UIView!
    
    private let keyboard = KeyboardManager()
    private let viewModel = InvitesLocationViewModel()
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private let date: Date?
    private let isShowProgressView: Bool
    
    // combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    required init(date: Date? = nil, showProgressView: Bool = true) {
        self.date = date
        self.isShowProgressView = showProgressView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        setupViews()
        addObsevers()
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        viewModel.input.requestLocations(keyword: nil)
            
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        keyboard.registerMonitor()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        keyboard.unregisterMonitor()
    }
  
}

private extension InvitesLocationController {
    
    func addObsevers() {
        
        navigationBar.backAction = { [unowned self] in
            if let navi = self.navigationController {
                navi.popViewController()
                return
            }
            self.dismiss(animated: true)
        }
        
        searchBar.returnHandler = { [unowned self] text in
            self.viewModel.input.requestLocations(keyword: text)
        }
        
        keyboard.action = { [unowned self] event in
            switch event {
            case .willShow(let info):
                let y = info.endFrame.origin.y
                UIView.animate(withDuration: info.duration, delay: .zero, options: .curveEaseIn) {
                    self.collectionView.height = y - self.collectionView.y
                }
            case .willHide(let info):
                UIView.animate(withDuration: info.duration) {
                    self.collectionView.height = ScreenHeight - self.collectionView.y
                }
            default:
                break
            }
        }
        
        viewModel.locationsResult
            .sink { [unowned self] success in
                if success {
                    self.adapter.performUpdates(animated: true)
                }
            }
            .store(in: &cancellables)
        
    }
    
    func setupViews() {
        
        navigationBar = NavigationBar().then {
            if self.navigationController == nil {
                $0.backStyle = .close
            }
            $0.backgroundColor = .black
        }
        
        let titleLabel = UILabel().then {
            $0.text = "Set Location"
            $0.textColor = .white
            $0.font = UIFont(type: .montserratExtraBold, size: 32.rpx)
            let x = 20.rpx
            let y = navigationBar.frame.maxY
            let size = $0.text!.size(font: $0.font)
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        searchBar = SearchBar().then {
            $0.frame = CGRect(x: 20.rpx, y: titleLabel.frame.maxY + 20.rpx, width: ScreenWidth - 40.rpx, height: 52.rpx)
            $0.backgroundColor = .white.withAlphaComponent(0.1)
            $0.cornerRadius = 10.rpx
            $0.textField.returnKeyType = .search
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.backgroundColor = .black
            let y = searchBar.frame.maxY + 25.rpx
            $0.frame = CGRect(x: .zero, y: y, width: ScreenWidth, height: ScreenHeight - y)
        }
        
        progressView1 = UIView().then {
            $0.isHidden = !self.isShowProgressView
            $0.backgroundColor = .white.withAlphaComponent(0.2)
            let width = 80.rpx
            let height = 4.0
            let x = (ScreenWidth - width * 2 - 5.rpx) / 2.0
            let y = (navigationBar.height - ScreenFit.statusBarHeight - height) / 2.0 + ScreenFit.statusBarHeight
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        progressView2 = UIView().then {
            $0.isHidden = !self.isShowProgressView
            $0.backgroundColor = .white
            let size = progressView1.size
            let x = progressView1.frame.maxX + 5.rpx
            let y = progressView1.y
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        view.addSubviews([navigationBar, titleLabel, searchBar, collectionView])
        navigationBar.addSubviews([progressView1, progressView2])
    }
    
}

extension InvitesLocationController: ListAdapterDataSource, ListSingleSectionControllerDelegate {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return viewModel.output.items
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return locationSection()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    private func locationSection() -> ListSectionController {
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? InvitesLocationCell,
                  let entity = item as? LocationEntity
            else { return }
            
            cell.title = entity.model.name
            cell.detail = entity.model.description
            cell.setLayout(entity.layout)
        }

        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context,
                  let entity = item as? LocationEntity
            else { return .zero }
            
            return CGSize(width: context.containerSize.width, height: entity.layout.height)
        }
        
        let sectionController = ListSingleSectionController(cellClass: InvitesLocationCell.self,
                                                            configureBlock: configureBlock,
                                                            sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        return sectionController
    }
    
    // MARK: - ListSingleSectionControllerDelegate
    
    func didSelect(_ sectionController: ListSingleSectionController, with object: Any) {
        
        if isShowProgressView {
            guard let date = date, let entity = object as? LocationEntity else { return }
            self.popHandler?(date, entity.model)
            
            if let navi = navigationController, let root = navi.children.first {
                navi.popToViewController(root, animated: true)
            }
            
        } else {
            
            guard let entity = object as? LocationEntity else { return }
            selectedHandler?(entity.model)
            self.dismiss(animated: true)
        }
        
    }
    
}
