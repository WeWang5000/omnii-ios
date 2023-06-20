//
//  ShareFriendsController.swift
//  omnii
//
//  Created by huyang on 2023/5/30.
//

import UIKit
import Combine
import CommonUtils
import IGListKit

enum ShareStyle {
    case moments
    case invites
}

class FriendsPickerController: UIViewController {
    
    var dismissHandler: (([FriendModel]?) -> Void)?
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private let keyboard = KeyboardManager()
    
    private var navigationBar: NavigationBar!
    private var searchBar: SearchBar!
    private var collectionView: UICollectionView!
    private var nexButton: UIButton!
    
    private var searchText: String?
    
    private let style: ShareStyle
    private let viewModel: FriendsViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    required init(style: ShareStyle) {
        self.style = style
        self.viewModel = FriendsViewModel(style: style)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        setupViews()
        addSubViewsObserver()
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        viewModel.requestFriends()
            .sink { [unowned self] success in
                if success { self.adapter.reloadData() }
            }
            .store(in: &cancellables)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        keyboard.registerMonitor()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
       
        keyboard.unregisterMonitor()
    }
    
    private func addSubViewsObserver() {
       
        navigationBar.backAction = { [unowned self] in
            self.dismiss()
        }
        
        searchBar.textChanged = { [unowned self] text in
            self.searchText = text
            self.adapter.performUpdates(animated: true, completion: nil)
        }
        
        keyboard.action = { [unowned self] event in
            switch event {
            case .willShow(let info):
                UIView.animate(withDuration: info.duration, delay: .zero, options: .curveEaseOut) {
                    let y = info.endFrame.origin.y
                    self.collectionView.height = y - self.searchBar.frame.maxY - 23.rpx
                }
            case .willHide(let info):
                UIView.animate(withDuration: info.duration, delay: .zero, options: .curveEaseOut) {
                    self.collectionView.height = self.nexButton.y - self.searchBar.frame.maxY - 23.rpx - 20.rpx
                }
            default:
                break
            }
        }
        
    }
    
    private func setupViews() {
        
        navigationBar = NavigationBar().then {
            $0.title = self.style == .moments ? "Friends Only" : "Invited Only"
            $0.backStyle = self.style == .moments ? .back : .close
            $0.backgroundColor = .black
        }
        
        searchBar = SearchBar().then {
            $0.frame = CGRect(x: 20.rpx, y: navigationBar.frame.maxY, width: ScreenWidth - 40.rpx, height: 52.rpx)
            $0.backgroundColor = .white.withAlphaComponent(0.1)
            $0.cornerRadius = 10.rpx
            $0.textField.returnKeyType = .done
        }
        
        nexButton = UIButton(type: .custom).then {
            let size = CGSize(width: 320.rpx, height: 55.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = ScreenHeight - ScreenFit.safeBottomHeight - size.height
            $0.frame = CGRect(x: x, y: y, size: size)
            $0.whiteBackgroundStyle(title: "Next")
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.backgroundColor = .black
            let y = searchBar.frame.maxY + 23.rpx
            let height = nexButton.y - y - 20.rpx
            $0.frame = CGRect(x: .zero, y: y, width: ScreenWidth, height: height)
        }
        
        nexButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubviews([navigationBar, searchBar, collectionView, nexButton])
    }
    
    @objc private func click(_ sender: UIButton) {
        dismiss()
    }

    private func dismiss() {
        dismissHandler?(viewModel.selectedFriends)
        switch style {
        case .moments:
            self.navigationController?.popViewController()
        case .invites:
            self.dismiss(animated: true)
        }
    }
}

extension FriendsPickerController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return viewModel.output.items(with: searchText)
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let _ = object as? SingleFriendCellModel {
            return friendsSection()
        } else if let _ = object as? AllFriendsCellModel {
            return allFriendsSection()
        } else if let _ = object as? LimitFriendsCellModel {
            return limitFriendsSection()
        }
        return clearFriendsSection()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    private func friendsSection() -> ListSectionController {
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? SingleFriendPickCell,
                  let viewModel = item as? SingleFriendCellModel
            else { return }
            
            cell.bindViewModel(viewModel)
        }

        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else { return CGSize() }
            return CGSize(width: context.containerSize.width, height: SingleFriendPickCell.cellHeight)
        }
        
        let sectionController = ListSingleSectionController(cellClass: SingleFriendPickCell.self,
                                                            configureBlock: configureBlock,
                                                            sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        return sectionController
    }
    
    private func allFriendsSection() -> ListSectionController {
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? AllFriendsPickCell,
                  let viewModel = item as? AllFriendsCellModel
            else { return }
            
            cell.bindViewModel(viewModel)
        }

        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else { return CGSize() }
            return CGSize(width: context.containerSize.width, height: AllFriendsPickCell.cellHeight)
        }

        let sectionController = ListSingleSectionController(cellClass: AllFriendsPickCell.self,
                                                            configureBlock: configureBlock,
                                                            sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        return sectionController
    }
    
    private func limitFriendsSection() -> ListSectionController {
        
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? LimitFriendsAvatarCell,
                  let viewModel = item as? LimitFriendsCellModel
            else { return }
            
            cell.bindViewModel(viewModel)
        }

        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else { return CGSize() }
            return CGSize(width: context.containerSize.width, height: LimitFriendsAvatarCell.cellHeight)
        }
        
        let sectionController = ListSingleSectionController(cellClass: LimitFriendsAvatarCell.self,
                                                            configureBlock: configureBlock,
                                                            sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        return sectionController
        
    }
    
    private func clearFriendsSection() -> ListSectionController {
        let configureBlock = { [unowned self] (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? ClearFriendsCell else { return }
            cell.clearHandler = { [unowned self] in
                self.viewModel.clear()
                self.adapter.performUpdates(animated: true)
            }
        }

        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else { return CGSize() }
            return CGSize(width: context.containerSize.width, height: ClearFriendsCell.cellHeight)
        }
        
        let sectionController = ListSingleSectionController(cellClass: ClearFriendsCell.self,
                                                            configureBlock: configureBlock,
                                                            sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        return sectionController
    }
    
}

extension FriendsPickerController: ListSingleSectionControllerDelegate {
    
    func didSelect(_ sectionController: ListSingleSectionController, with object: Any) {
        if let cellModel = object as? SingleFriendCellModel {
            if style == .invites,
               !cellModel.isSelected,
                self.viewModel.selectedFriends.count >= 12 { // 限制选中个数
                return
            }
            
            self.viewModel.selectedToggle(for: cellModel)
            
            adapter.performUpdates(animated: true)
            
        } else if let cellModel = object as? AllFriendsCellModel {
            cellModel.selectedToggle()
            cellModel.isSelected ? self.viewModel.input.selectAll() : self.viewModel.input.clear()
            adapter.performUpdates(animated: true)
        }
    }
    
}
