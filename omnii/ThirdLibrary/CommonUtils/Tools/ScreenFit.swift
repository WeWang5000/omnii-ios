//
//  ScreenFit.swift
//  omnii
//
//  Created by huyang on 2023/4/20.
//

import Foundation
import DeviceKit

public let ScreenWidth = UIScreen.main.bounds.size.width
public let ScreenHeight = UIScreen.main.bounds.size.height


public enum ScreenFit {
    
    public static var statusBarHeight: CGFloat = {
        if #available(iOS 13.0, *) {
            let statusManager = UIApplication.shared.windows.first?.windowScene?.statusBarManager
            return statusManager?.statusBarFrame.size.height ?? 20.0
        } else {
            return UIApplication.shared.statusBarFrame.size.height
        }
    }()
    
    public static var navigationBarHeight: CGFloat = {
        return 44.0
    }()
    
    public static var navigationHeight: CGFloat = {
        return navigationBarHeight + statusBarHeight
    }()
    
    public static var safeBottomHeight: CGFloat = {
        var height: CGFloat = 0
        if Device.current.hasSensorHousing {
            if statusBarHeight >= 44 {
                height = 34
            }else {
                height = 0
            }
            return height
        }
        if Device.current.isPad {
            if statusBarHeight >= 23 {
                height = 15.0
            }else {
                height = 0.0
            }
        }
        return height
    }()
    
}
