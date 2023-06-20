//
//  UIViewController+Omnii.swift
//  omnii
//
//  Created by huyang on 2023/5/29.
//

import UIKit
import CommonUtils
import PopupDialog

// MARK: - default popup
extension UIViewController {
    
    func pickerSheet(items: [PickerEntity],
                     height: Double,
                     title: String,
                     buttonTitle: String,
                     confirmDismiss: Bool = false,
                     actionHandler: PickerSheetController.handler? = nil) -> PickerSheetController {
        let picker = PickerSheetController(items: items,
                                           title: title,
                                           buttonTitle: buttonTitle,
                                           confirmDismiss: confirmDismiss,
                                           actionHandler: actionHandler)
        picker.modalPresentationStyle = .fullScreen
        picker.view.frame = CGRect(x: 0, y: ScreenHeight - height, width: ScreenWidth, height: height)
        picker.view.roundCorners([.topLeft, .topRight], radius: 30.rpx)
        return picker
    }
    
    /// warning message alert
    func warningAlert(title: String, message: String) {
        let popup = PopupDialog(title: title, message: message, transitionStyle: .alert)
        let confirm = GradientButton(title: "Confirm", action: nil)
        popup.addButton(confirm)
        present(popup, animated: true)
    }
    
}

extension UIViewController {
    
    typealias TransitionStyle = PopupTransitionStyle
    typealias OverlayViewStyle = PopupOverlayView.Style
    typealias AnimationHandler = TransitionHandler.handler
    typealias InteractiveHandler = InteractiveTransition.handler
    
    func present(_ viewController: UIViewController,
                 transionStyle: TransitionStyle,
                 tapGestureDismissal: Bool = false,
                 panGestureDismissal: Bool = false,
                 overlayStyle: OverlayViewStyle = .none,
                 tapGestureBegan: (() -> Void)? = nil,
                 showCompletion: (() -> Void)? = nil,
                 dismissCompletion: (() -> Void)? = nil) {
        
        let popup = Popup(viewController: viewController,
                          transitionStyle: transionStyle,
                          tapGestureDismissal: tapGestureDismissal,
                          panGestureDismissal: panGestureDismissal,
                          overlayStyle: overlayStyle,
                          tapGestureBegan: tapGestureBegan,
                          completion: dismissCompletion)
        
        self.present(popup, animated: true, completion: showCompletion)
    }
    
    // present sheet controller
    func presentSheet(_ viewController: UIViewController,
                      tapGestureDismissal: Bool = false,
                      panGestureDismissal: Bool = false,
                      overlayStyle: OverlayViewStyle = .none,
                      showHandler: AnimationHandler? = nil,
                      dismissHandler: AnimationHandler? = nil,
                      panHandler: InteractiveHandler? = nil,
                      tapGestureBegan: (() -> Void)? = nil,
                      showCompletion: (() -> Void)? = nil,
                      dismissCompletion: (() -> Void)? = nil) {
        
        let handler = TransitionHandler(present: showHandler, dismiss: dismissHandler)
        
        let popup = Popup(viewController: viewController,
                          transitionStyle: .sheet(handler),
                          tapGestureDismissal: tapGestureDismissal,
                          panGestureDismissal: panGestureDismissal,
                          overlayStyle: overlayStyle,
                          tapGestureBegan: tapGestureBegan,
                          panGestureState: panHandler,
                          completion: dismissCompletion)
        
        self.present(popup, animated: true, completion: showCompletion)
    }
    
    // present pick sheet controller
    // 带选择按钮的列表
    func presentPickerSheet(items: [PickerEntity],
                            height: Double,
                            title: String,
                            buttonTitle: String,
                            tapGestureDismissal: Bool = false,
                            panGestureDismissal: Bool = false,
                            overlayStyle: PopupOverlayView.Style = .none,
                            pickHandler: PickerSheetController.handler? = nil,
                            showHandler: TransitionHandler.handler? = nil,
                            dismissHandler: TransitionHandler.handler? = nil,
                            panHandler: InteractiveTransition.handler? = nil,
                            tapGestureBegan: (() -> Void)? = nil,
                            showCompletion: (() -> Void)? = nil,
                            dismissCompletion: (() -> Void)? = nil) {
        
        let picker = pickerSheet(items: items,
                                 height: height,
                                 title: title,
                                 buttonTitle: buttonTitle,
                                 actionHandler: pickHandler)
        
        let handler = TransitionHandler(present: showHandler, dismiss: dismissHandler)
        
        let popup = Popup(viewController: picker,
                          transitionStyle: .sheet(handler),
                          tapGestureDismissal: tapGestureDismissal,
                          panGestureDismissal: panGestureDismissal,
                          overlayStyle: overlayStyle,
                          tapGestureBegan: tapGestureBegan,
                          panGestureState: panHandler,
                          completion: dismissCompletion)
        
        self.present(popup, animated: true, completion: showCompletion)
    }
    
}

// MARK: - dismiss
extension UIViewController {
    
    func dismiss(to viewController: AnyClass, animated: Bool = true) {
        var node = self
        while let presenting = node.presentingViewController {
            if presenting.isKind(of: viewController) {
                presenting.dismiss(animated: animated)
                return
            }
            node = presenting
        }
    }
    
    func dismissToRoot(animated: Bool = true) {
        var node = self
        while let presenting = node.presentingViewController {
            node = presenting
        }
        node.dismiss(animated: animated)
    }
    
}
