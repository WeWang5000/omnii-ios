//
//  AblumViewController.swift
//  omnii
//
//  Created by huyang on 2023/5/9.
//

import UIKit
import IGListKit
import IGListDiffKit
import PopupDialog

class AblumViewController: UIViewController {
    
    var photoSelectedHandler: ((PhotoModel) -> Void)?
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 6)
    }()
    
    private lazy var ablumView: AblumView = {
        return AblumView(frame: UIScreen.main.bounds)
    }()
    
    private var ablums: [PhotoCollectionModel]
    private var collectionModel: PhotoCollectionModel?
    
    init(ablums: [PhotoCollectionModel]) {
        self.ablums = ablums
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ablums = ablums.filter{ $0.name == "Recents" }
        if let collection = ablums.first {
            self.collectionModel = collection
        }
        
        view.addSubview(ablumView)
        
        adapter.collectionView = ablumView.collectionView
        adapter.dataSource = self
        
        ablumView.ablumAction = { [unowned self] type in
            switch type {
            case .close:
                dismiss()
            case .openAblumList:
                self.presentAblumList()
            }
        }
    }

    private func presentAblumList() {
        let list = AblumListController(ablums: ablums, title: self.collectionModel!.name)
        self.present(list, transionStyle: .sheet)
        
        list.ablumListAction = { [unowned self] object in
            self.collectionModel = object
            self.ablumView.updateTitle(title: object.name)
            self.adapter.reloadData()
        }
    }
    
    private func dismiss() {
        self.dismiss(animated: true)
    }
    
}

extension AblumViewController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        if let object = collectionModel {
            return [object]
        }
        return [ListDiffable]()
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let grid = PhotoGridSectionController()
        grid.delegate = self
        return grid
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}

extension AblumViewController: PhotoGridSectionControllerDelegate {
    
    func didSelect(_ sectionController: PhotoGridSectionController, with object: PhotoModel) {
        self.navigationController?.pushViewController(MomentsEditingController(photo: object))
        if let handler = photoSelectedHandler {
            handler(object)
        }
    }
    
}
