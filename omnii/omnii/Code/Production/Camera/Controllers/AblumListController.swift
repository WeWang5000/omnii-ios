//
//  AblumListController.swift
//  omnii
//
//  Created by huyang on 2023/5/10.
//

import UIKit
import CommonUtils
import IGListKit
import IGListDiffKit

class AblumListController: UIViewController {
    
    var ablumListAction: ((PhotoCollectionModel) -> Void)?
    
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private var ablums: [PhotoCollectionModel]
    private var ablumName: String
    
    private var closeButton: UIButton?
    private var titleButton: UIButton?
    
    init(ablums: [PhotoCollectionModel], title: String) {
        self.ablums = ablums
        self.ablumName = title
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(hexString: "#151517")!
        view.roundCorners([.topLeft, .topRight], radius: 30.rpx)
        let y = ScreenFit.statusBarHeight
        view.frame = CGRect(x: 0, y: y, width: ScreenWidth, height: ScreenHeight - y)
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

}

extension AblumListController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return ablums
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? AblumListCell,
                    let model = item as? PhotoCollectionModel
            else { return }
            
            cell.bindModel(model)
        }

        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else { return CGSize() }
            return CGSize(width: context.containerSize.width, height: 90.rpx)
        }
        
        let sectionController = ListSingleSectionController(cellClass: AblumListCell.self,
                                                            configureBlock: configureBlock,
                                                            sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        return sectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}


extension AblumListController: ListSingleSectionControllerDelegate {
    
    func didSelect(_ sectionController: ListSingleSectionController, with object: Any) {
        if let action = ablumListAction {
            action(object as! PhotoCollectionModel)
        }
        self.dismiss(animated: true)
    }
    
}

 
private extension AblumListController {
    
    func setupViews() {
        
        collectionView.do {
            $0.backgroundColor = self.view.backgroundColor
            let x = 0.0
            let y = 76.0
            let width = self.view.width
            let height = self.view.height - y - ScreenFit.safeBottomHeight
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        closeButton = UIButton(imageName: "camera_close").then {
            let size = CGSize(width: 40.rpx, height: 40.rpx)
            let origin = CGPoint(x: 20.0, y: 16.0)
            $0.frame = CGRect(origin: origin, size: size)
            let bgColor = UIColor.white.withAlphaComponent(0.1)
            let bgImage = UIImage(color: bgColor, size: size).withRoundedCorners()
            if let image = bgImage {
                $0.setBackgroundImage(image, for: .normal)
            }
        }
        
        titleButton = UIButton(type: .custom).then {
            let normal = UIImage(named: "ablum_up_normal")?.rotated(by: .pi)
            let highlight = UIImage(named: "ablum_up_highlight")?.rotated(by: .pi)
            $0.setImage(normal, for: .normal)
            $0.setImage(highlight, for: .highlighted)
            $0.titleLabel?.font = UIFont(type: .montserratSemiBlod, size: 20.rpx)
            $0.titleLabel?.lineBreakMode = .byTruncatingTail
            $0.setTitleForAllStates(ablumName)
            $0.setImageAlign(to: .right(2.0))
            let width = self.view.width / 2.0
            let height = 40.rpx
            let x = (self.view.width - width) / 2.0
            let y = closeButton!.y
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        closeButton!.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        titleButton!.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubview(closeButton!)
        view.addSubview(titleButton!)
        view.addSubview(collectionView)
    }
    
    @objc private func click(_ sender: UIButton) {
        dismiss()
    }
    
    private func dismiss() {
        self.dismiss(animated: true)
    }
    
}
