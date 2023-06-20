//
//  UserCache.swift
//  omnii
//
//  Created by huyang on 2023/5/20.
//

import Foundation

let UserCache = SimpleCache<SimpleCacheKey>()

// MARK: - Omnii User Cache

enum SimpleCacheKey: String {
    // 新用户展示，拍摄页面相册提示框
    case cameraAblumBubble
    // 新用户展示，创建 moments 私有类型弹窗提示
    case momentsIncognitoDialog
    // 新用户展示，moments 全屏提示信息
    case momentsInfoOverlyView
    // 新用户展示，invites 全屏提示信息
    case invitesInfoOverlyView
}


extension SimpleCacheKey: SimpleCacheable {
    
    var key: String {
        let userId = Auth.userId ?? "unkown"
        return userId + "." + self.rawValue
    }
    
}


// MARK: - protocol

protocol SimpleCacheable {
    var key: String { get }
}

final class SimpleCache<K: SimpleCacheable> {
    
    func set(_ value: Any?, forKey cacheable: K) {
        UserDefaults.standard.set(value, forKey: cacheable.key)
    }
    
    func value(forKey cacheable: K) -> Any? {
        UserDefaults.standard.value(forKey: cacheable.key)
    }
    
}
