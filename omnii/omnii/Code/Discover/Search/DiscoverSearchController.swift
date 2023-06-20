//
//  DiscoverSearchController.swift
//  omnii
//
//  Created by huyang on 2023/6/17.
//

import UIKit
import Pageable
import CommonUtils
import SwiftRichString

final class DiscoverSearchController: UIViewController {
    
    private var searchBar: SearchBar!
    private var cancelButton: UIButton!
    private var locationButton: UIButton!
    private var userButton: UIButton!
    private var separator: CALayer!
    private(set) var pageController: PageViewController!
    
    private lazy var locationVC: DiscoverSearchLocationController = {
       return DiscoverSearchLocationController()
    }()
    
    private lazy var userVC: DiscoverSearchUserController = {
       return DiscoverSearchUserController()
    }()
    
//    let interactor = PageableInteractiveTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        setupViews()
        addObserves()
    }
    
    private func setupViews() {
        
        searchBar = SearchBar().then {
            $0.frame = CGRect(x: 20.rpx, y: ScreenFit.statusBarHeight, width: 267.rpx, height: 52.rpx)
            $0.backgroundColor = .white.withAlphaComponent(0.1)
            $0.cornerRadius = 10.rpx
            $0.textField.returnKeyType = .search
        }
        
        cancelButton = UIButton(type: .custom).then {
            let title = "Cancel"
            let font = UIFont(type: .montserratRegular, size: 16.rpx)!
            $0.setTitleForAllStates(title)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(.white.withAlphaComponent(0.6), for: .highlighted)
            $0.titleLabel?.font = font
            let x = searchBar.frame.maxX + 12.rpx
            let y = searchBar.y
            let width = title.width(font: font)
            let height = searchBar.height
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        locationButton = UIButton(type: .custom).then {
            let title = "Location"
            let normalStyle = Style {
                $0.color = Color(hexString: "#FFFFFF", transparency: 0.4)
                $0.font = UIFont(type: .montserratRegular, size: 18.rpx)
            }
            let selectedStyle = Style {
                $0.color = Color(hexString: "#FFFFFF")
                $0.font = UIFont(type: .montserratExtraBold, size: 18.rpx)
            }
            $0.isSelected = true
            $0.setAttributedTitle(title.set(style: normalStyle), for: .normal)
            $0.setAttributedTitle(title.set(style: normalStyle), for: [.normal, .highlighted])
            $0.setAttributedTitle(title.set(style: selectedStyle), for: .selected)
            $0.setAttributedTitle(title.set(style: selectedStyle), for: [.selected, .highlighted])
            let width = title.width(style: selectedStyle)
            let height = 58.rpx
            let x = (ScreenWidth / 2.0 - width) / 2.0
            let y = searchBar.frame.maxY
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        userButton = UIButton(type: .custom).then {
            let title = "Users"
            let normalStyle = Style {
                $0.color = Color(hexString: "#FFFFFF", transparency: 0.4)
                $0.font = UIFont(type: .montserratRegular, size: 18.rpx)
            }
            let selectedStyle = Style {
                $0.color = Color(hexString: "#FFFFFF")
                $0.font = UIFont(type: .montserratExtraBold, size: 18.rpx)
            }
            $0.isSelected = false
            $0.setAttributedTitle(title.set(style: normalStyle), for: .normal)
            $0.setAttributedTitle(title.set(style: normalStyle), for: [.normal, .highlighted])
            $0.setAttributedTitle(title.set(style: selectedStyle), for: .selected)
            $0.setAttributedTitle(title.set(style: selectedStyle), for: [.selected, .highlighted])
            let width = title.width(style: selectedStyle)
            let height = 58.rpx
            let x = (ScreenWidth / 2.0 - width) / 2.0 + ScreenWidth / 2.0
            let y = searchBar.frame.maxY
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        separator = CALayer().then {
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.15).cgColor
            $0.frame = CGRect(x: .zero, y: locationButton.frame.maxY, width: ScreenWidth, height: 1.0)
        }
        
        pageController = PageViewController().then {
            $0.dataSource = self
            $0.delegate = self
            let y = separator.frame.maxY
            $0.view.frame = CGRect(x: .zero, y: y, width: ScreenWidth, height: ScreenHeight - y)
        }
        
//        interactor.viewController = pageController
//        let panRecognizer = UIPanGestureRecognizer(target: interactor, action: #selector(PageableInteractiveTransition.handlePan(_:)))
//        panRecognizer.cancelsTouchesInView = false
//        pageController.view.addGestureRecognizer(panRecognizer)
        
        cancelButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        userButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubview(searchBar)
        view.addSubview(cancelButton)
        view.addSubview(locationButton)
        view.addSubview(userButton)
        view.layer.addSublayer(separator)
        addChild(pageController)
        view.addSubview(pageController.view)
        
    }
    
    private func addObserves() {
        
        searchBar.textChanged = { [unowned self] text in
            self.locationVC.keyword = text
            self.userVC.keyword = text
        }
        
    }
    
    @objc private func click(_ sender: UIButton) {
        if sender == cancelButton {
            dismiss(animated: true)
        } else if sender == locationButton {
            locationButton.isSelected.toggle()
            userButton.isSelected.toggle()
            pageController.display(.previous)
            view.endEditing(true)
        } else if sender == userButton {
            locationButton.isSelected.toggle()
            userButton.isSelected.toggle()
            pageController.display(.next)
            view.endEditing(true)
        }
    }
    
}


extension DiscoverSearchController: PageViewControllerDatasource {
    
    func objects(for pageViewController: PageViewController) -> [PageDiffable] {
        return ["location", "user"]
    }
    
    func pageViewController(_ pageViewController: PageViewController, controllerFor object: PageDiffable) -> Pageable? {
        if object.isEqual(to: "location") {
            return locationVC
        }
        
        if object.isEqual(to: "user") {
            return userVC
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: PageViewController, animationControllerForFrom fromVC: Pageable, to toVC: Pageable) -> UIViewControllerAnimatedTransitioning? {
        if fromVC.isKind(of: DiscoverSearchLocationController.self) {
            return PageableTransitionAnimator(direction: .right)
        } else {
            return PageableTransitionAnimator(direction: .left)
        }
    }
    
//    func pageViewController(_ pageViewController: PageViewController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return interactor.hasStarted ? interactor : nil
//    }
    
}

extension DiscoverSearchController: PageViewControllerDelegate {
    
   
    
}
