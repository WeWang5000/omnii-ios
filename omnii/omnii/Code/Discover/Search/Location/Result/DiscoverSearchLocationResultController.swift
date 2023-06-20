//
//  DiscoverSearchLocationResultController.swift
//  omnii
//
//  Created by huyang on 2023/6/18.
//

import UIKit
import CommonUtils

class DiscoverSearchLocationResultController: DiscoverController {
    
    private var secondarySwitchBar: DiscoverSwitchBar!
    
    private var resultViewModel: DiscoverSearchLocationResultViewModel {
        return viewModel as! DiscoverSearchLocationResultViewModel
    }
    
    private let geo: GeoModel
    
    required init(geo: GeoModel) {
        self.geo = geo
        super.init(viewModel: DiscoverSearchLocationResultViewModel())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        addObsevers()
        
        let params = [
            "longitude" : geo.longitude,
            "latitude"  : geo.latitude
        ]
        resultViewModel.request(params: params, more: false)
    }
    
    func setupViews() {
        
        browseButton.isHidden = false
        navigationBar.title = geo.name
        
        secondarySwitchBar = DiscoverSwitchBar(titles: DiscoverHomeViewModel.SecondaryKey.allRaws, fontSize: 14.rpx).then {
            let size = $0.size
            let x = (ScreenWidth - size.width) / 2.0
            let y = navigationBar.frame.maxY - 10.rpx
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        view.addSubview(secondarySwitchBar)
    }
        
    func addObsevers() {
        
        secondarySwitchBar.action = { [unowned self] text in
            guard let key = DiscoverSearchLocationResultViewModel.SecondaryKey(rawValue: text) else { return }
            self.resultViewModel.switchSecondaryKey(to: key)
        }
        
    }
    

}
