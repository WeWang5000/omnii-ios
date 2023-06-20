//
//  Popup.swift
//  omnii
//
//  Created by huyang on 2023/5/14.
//

import Foundation
import UIKit

final public class Popup: UIViewController {
    
    // MARK: - Private / Internal

    /// First init flag
    fileprivate var initialized = false
    
    /// StatusBar display related
    fileprivate let hideStatusBar: Bool
    fileprivate var statusBarShouldBeHidden: Bool = false

    /// The completion handler
    fileprivate var completion: (() -> Void)?
    
    /// The Tap gesture bengan handler
    fileprivate var tapGestureBegan: (() -> Void)?
    
    /// The custom transition presentation manager
    fileprivate var presentationManager: PresentationManager!
    
    /// Interactor class for pan gesture dismissal
    fileprivate lazy var interactor = InteractiveTransition()
    
    /// Returns the controllers view
    fileprivate var popupContainerView: UIView {
        return viewController.view
    }
    
    // MARK: - Public
    
    /// The content view of the popup viewController
    public var viewController: UIViewController
    
    
    /*!
     Creates a popup containing a custom view

     - parameter viewController:   A custom view controller to be displayed
     - parameter transitionStyle:  The viewController transition style
     - parameter tapGestureDismissal: Indicates if viewController can be dismissed via tap gesture
     - parameter panGestureDismissal: Indicates if viewController can be dismissed via pan gesture
     - parameter hideStatusBar:    Whether to hide the status bar on viewController presentation
     - parameter completion:       Completion block invoked when viewController was dismissed

     - returns: Popup with a custom view controller
     */
    public init(viewController: UIViewController,
                transitionStyle: PopupTransitionStyle = .sheet,
                tapGestureDismissal: Bool = false,
                panGestureDismissal: Bool = false,
                hideStatusBar: Bool = false,
                overlayStyle: PopupOverlayView.Style = .none,
                tapGestureBegan:(() -> Void)? = nil,
                panGestureState: ((InteractiveTransition.State) -> Void)? = nil,
                completion: (() -> Void)? = nil) {
        
        self.viewController = viewController
        self.hideStatusBar = hideStatusBar
        self.completion = completion
        self.tapGestureBegan = tapGestureBegan
        
        super.init(nibName: nil, bundle: nil)
            
        // Init the presentation manager
        presentationManager = PresentationManager(transitionStyle: transitionStyle, interactor: interactor, overlayStyle: overlayStyle)
            
        // Assign the interactor view controller
        interactor.viewController = self

        // Define presentation styles
        transitioningDelegate = presentationManager
        modalPresentationStyle = .custom
            
        // StatusBar setup
        modalPresentationCapturesStatusBarAppearance = true
            
        // Add our custom view to the container
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        // Allow for dialog dismissal on background tap
        if tapGestureDismissal {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            tapRecognizer.cancelsTouchesInView = false
            view.addGestureRecognizer(tapRecognizer)
        }
        // Allow for viewController dismissal on viewController pan gesture
        if panGestureDismissal {
            interactor.stateHandler = panGestureState
            let panRecognizer = UIPanGestureRecognizer(target: interactor, action: #selector(InteractiveTransition.handlePan))
            panRecognizer.cancelsTouchesInView = false
            popupContainerView.addGestureRecognizer(panRecognizer)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !initialized else { return }
        initialized = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statusBarShouldBeHidden = hideStatusBar
        UIView.animate(withDuration: 0.15) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    deinit {
        completion?()
        completion = nil
    }
    
}

// MARK: - Dismissal related

extension Popup {
    
    @objc fileprivate func handleTap(_ sender: UITapGestureRecognizer) {

        // Make sure it's not a tap on the viewController but the background
        let point = sender.location(in: popupContainerView)
        guard !popupContainerView.point(inside: point, with: nil) else { return }
        tapGestureBegan?()
        dismiss()
    }

    /*!
     Dismisses the popup viewController
     */
    public func dismiss(_ completion: (() -> Void)? = nil) {
        self.dismiss(animated: true) {
            completion?()
        }
    }
    
}

