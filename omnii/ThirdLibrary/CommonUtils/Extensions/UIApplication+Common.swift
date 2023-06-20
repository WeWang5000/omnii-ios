//
//  UIApplication+Common.swift
//  omnii
//
//  Created by huyang on 2023/5/4.
//

import UIKit

public extension UIApplication {
    
    func keyWindow() -> UIWindow? {
        let window = self.connectedScenes.filter {
            $0.activationState == .foregroundActive
        }.first(where: { $0 is UIWindowScene })
            .flatMap( { $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
        return window
    }
    
    func topMostViewController() -> UIViewController? {
        
        let vc = self.connectedScenes.filter {
            $0.activationState == .foregroundActive
        }.first(where: { $0 is UIWindowScene })
            .flatMap( { $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)?
            .rootViewController?
            .topMostViewController()
        
        return vc
    }
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let topController = topMostViewController() else { return }
        topController.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    func interfaceOrientation() -> UIInterfaceOrientation? {
        let interfaceOrientation = self.connectedScenes.filter {
            $0.activationState == .foregroundActive
        }.first(where: { $0 is UIWindowScene })
            .flatMap( { $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)?
            .windowScene?
            .interfaceOrientation
        
        return interfaceOrientation
    }
    
}
