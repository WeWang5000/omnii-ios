//
//  SharePageable.swift
//  omnii
//
//  Created by huyang on 2023/5/22.
//

import UIKit
import CommonUtils
import Pageable

final class ProductionPageableController: UIViewController {
    
    private var pageController: PageViewController!
    private var momentsButton: UIButton!
    private var invitesButton: UIButton!
    
    deinit {
        print("SharePageableManager")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageController()
        addBottomButtons()
    }
    
    func setupPageController() {
        pageController = PageViewController()
        pageController.delegate = self
        pageController.dataSource = self
        pageController.view.frame = UIScreen.main.bounds
        addChild(pageController)
        view.addSubview(pageController.view)
    }
    
    private func addBottomButtons() {
        
        momentsButton = UIButton(type: .custom).then {
            let title = "Moments"
            $0.isSelected = true
            $0.setTitleForAllStates(title)
            let normalColor = UIColor(hexString: "#808080")
            $0.setTitleColor(normalColor, for: .normal)
            $0.setTitleColor(normalColor.withAlphaComponent(0.7), for: [.normal, .highlighted])
            $0.setTitleColor(.white, for: .selected)
            $0.setTitleColor(.white.withAlphaComponent(0.7), for: [.selected, .highlighted])
            let font = UIFont(type: .montserratRegular, size: 16.rpx)
            $0.titleLabel?.font = font
            let attrs: [NSAttributedString.Key : Any] = [.font: font!]
            let size = title.size(attributes: attrs)
            let x = 112.rpx
            let y = ScreenHeight - ScreenFit.safeBottomHeight - size.height - (66.rpx - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        }
        
        invitesButton = UIButton(type: .custom).then {
            let title = "Invites"
            $0.setTitleForAllStates(title)
            let normalColor = UIColor(hexString: "#808080")
            $0.setTitleColor(normalColor, for: .normal)
            $0.setTitleColor(normalColor.withAlphaComponent(0.7), for: [.normal, .highlighted])
            $0.setTitleColor(.white, for: .selected)
            $0.setTitleColor(.white.withAlphaComponent(0.7), for: [.selected, .highlighted])
            let font = UIFont(type: .montserratRegular, size: 16.rpx)
            $0.titleLabel?.font = font
            let attrs: [NSAttributedString.Key : Any] = [.font: font!]
            let size = title.size(attributes: attrs)
            let x = ScreenWidth - 112.rpx - size.width
            let y = momentsButton.y
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        }
        
        momentsButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        invitesButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubview(momentsButton)
        view.addSubview(invitesButton)
    }
    
    @objc private func click(_ sender: UIButton) {
        if sender == momentsButton, !momentsButton.isSelected {
            invitesButton.isSelected.toggle()
            momentsButton.isSelected.toggle()
            pageController.display(.previous)
        }
        
        if sender == invitesButton, !invitesButton.isSelected {
            invitesButton.isSelected.toggle()
            momentsButton.isSelected.toggle()
            pageController.display(.next)
        }
    }
    
}

extension ProductionPageableController: PageViewControllerDatasource {

    func objects(for pageViewController: PageViewController) -> [PageDiffable] {
        return ["Moments", "Invites"]
    }

    func pageViewController(_ pageViewController: PageViewController, controllerFor object: PageDiffable) -> Pageable? {
        
        if object.isEqual(to: "Moments") {
            if let moments = pageViewController.dequeueReusableController(with: "\(CameraViewController.self)") {
                return moments
            }
            
            let moments = CameraViewController()
            return moments
        }
        
        if object.isEqual(to: "Invites") {
            if let invites = pageViewController.dequeueReusableController(with: "\(InvitesViewController.self)") {
                return invites
            }
            let invites = InvitesViewController()
            return invites
        }
        
        return nil
    }

}

extension ProductionPageableController: PageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: PageViewController, shouldDisplay controller: Pageable, forObject object: PageDiffable) -> Bool {
        return true
    }
    
    func pageViewController(_ pageViewController: PageViewController, didEndDisplaying controller: Pageable, forObject object: PageDiffable) {
        
    }
    
    func pageViewController(_ pageViewController: PageViewController, animationControllerForFrom fromVC: Pageable, to toVC: Pageable) -> UIViewControllerAnimatedTransitioning? {
        if fromVC.isKind(of: CameraViewController.self) {
            return PageableTransitionAnimator(direction: .right)
        } else {
            return PageableTransitionAnimator(direction: .left)
        }
    }
    
}


// MARK: - transition animator

class PageableTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Direction {
    case left
    case right
    }

    var to: UIViewController!
    var from: UIViewController!
    let inDuration: TimeInterval
    let outDuration: TimeInterval
    let direction: Direction

    init(direction: Direction) {
        self.inDuration = 0.2
        self.outDuration = 0.2
        self.direction = direction
        super.init()
    }

    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return direction == .left ? inDuration : outDuration
    }

    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch direction {
        case .left:
            guard let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
                let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
            
            self.to = to
            self.from = from

            let container = transitionContext.containerView
            container.addSubview(to.view)
            container.addSubview(from.view)
            
            to.view.x = -from.view.width
            UIView.animate(withDuration: inDuration, delay: 0.0, options: [.curveEaseOut]) { [weak self] in
                guard let self = self else { return }
                self.from.view.x = self.from.view.width
                self.to.view.x = .zero
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
        case .right:
            guard let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
                let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
            
            self.to = to
            self.from = from
            
            let container = transitionContext.containerView
            container.addSubview(to.view)
            container.addSubview(from.view)
            
            to.view.x = from.view.bounds.size.width
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseOut], animations: { [weak self] in
                guard let self = self else { return }
                self.from.view.x = -self.from.view.width
                self.to.view.x = .zero
            }, completion: { _ in
                self.from.view.x = .zero
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        }
    }
}
