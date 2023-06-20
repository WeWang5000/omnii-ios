//
//  HomeViewController.swift
//  omnii
//
//  Created by huyang on 2023/6/19.
//

import UIKit
import CommonUtils

class HomeViewController: UIViewController {

    private var discoverButton: UIButton!
    private var productionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBlue
        setupViews()
    }
    
    private func setupViews() {
        
        discoverButton = UIButton(imageName: "home_discover").then {
            $0.contentMode = .center
            let size = CGSize(width: 36.rpx, height: 36.rpx)
            let x = 20.rpx
            let y = ScreenFit.statusBarHeight + 20.rpx
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        productionButton = UIButton(imageName: "home_production").then {
            $0.contentMode = .center
            let size = CGSize(width: 69.rpx, height: 69.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = ScreenHeight - ScreenFit.safeBottomHeight - size.height - 22.rpx
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        discoverButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        productionButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubviews([discoverButton, productionButton])
    }
    
    @objc private func click(_ sender: UIButton) {
        if sender == discoverButton {
            presentDiscover()
        } else if sender == productionButton {
            presentProduction()
        }
    }
    
    private func presentDiscover() {
        let vc = NavigationController(rootViewController: DiscoverHomeController())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func presentProduction() {
        let vc = ProductionPageableController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}
