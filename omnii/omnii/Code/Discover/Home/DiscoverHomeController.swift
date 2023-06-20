//
//  DiscoverRecommendController.swift
//  omnii
//
//  Created by huyang on 2023/6/18.
//

import UIKit
import CommonUtils

final class DiscoverHomeController: DiscoverController {
    
    private var primarySwitchBar: DiscoverSwitchBar!
    private var secondarySwitchBar: DiscoverSwitchBar!
    
    private var recommentViewModel: DiscoverHomeViewModel {
        return viewModel as! DiscoverHomeViewModel
    }
    
    override init(viewModel: DiscoverViewModel = DiscoverHomeViewModel()) {
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        addObsevers()
        
        primarySwitchBar.selectTitle(recommentViewModel.primaryKey.rawValue)
        browseButton.isHidden = (recommentViewModel.primaryKey != .nearby)
        
        // 获取当前坐标卡片
        if let coor = LocationManager.shared.userCoordinate {
            recommentViewModel.input.updateCoordinate(coordinate: coor)
        }
        recommentViewModel.request(params: nil, more: false)
    }
    
    func setupViews() {
        
        navigationBar.updateRightButton(imageName: "search")
        
        primarySwitchBar = DiscoverSwitchBar(titles: DiscoverHomeViewModel.PrimaryKey.allRaws, fontSize: 16.rpx).then {
            let size = $0.size
            let x = (ScreenWidth - size.width) / 2.0
            let y = (ScreenFit.omniiNavigationBarHeight - size.height) / 2.0 + ScreenFit.statusBarHeight
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        secondarySwitchBar = DiscoverSwitchBar(titles: DiscoverHomeViewModel.SecondaryKey.allRaws, fontSize: 14.rpx).then {
            let size = $0.size
            let x = (ScreenWidth - size.width) / 2.0
            let y = navigationBar.frame.maxY - 10.rpx
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        view.addSubview(primarySwitchBar)
        view.addSubview(secondarySwitchBar)
    }
        
    func addObsevers() {
        
        navigationBar.rightItemAction = { [unowned self] in
            let vc = DiscoverSearchController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        
        primarySwitchBar.action = { [unowned self] text in
            guard let key = DiscoverHomeViewModel.PrimaryKey(rawValue: text) else { return }
            self.recommentViewModel.switchPrimaryKey(to: key)
            browseButton.isHidden = (key != .nearby)
            if key != .nearby {
                showVerticalCollectionView(animated: false)
            } else {
                if !browseButton.isSelected {
                    showHorizontalCollectionView(animated: false)
                }
            }
        }
        
        secondarySwitchBar.action = { [unowned self] text in
            guard let key = DiscoverHomeViewModel.SecondaryKey(rawValue: text) else { return }
            self.recommentViewModel.switchSecondaryKey(to: key)
        }
        
    }
    
}
