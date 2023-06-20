//
//  AuthManager.swift
//  omnii
//
//  Created by huyang on 2023/5/15.
//

import CommonUtils

extension UserDefaultsKey {
    static let authKey = Key<AuthModel>("auth.key")
}

final class Auth {
    
    public static let shared = Auth()
    
    private var user: AuthModel?

    init() {
        user = UserDefaults.standard.get(for: .authKey)
    }
    
    public static var user: AuthModel? {
        return shared.user
    }
    
    public static var userId: String? {
        return shared.user?.userId
    }
    
    public static var sub: String? {
        return shared.user?.sub
    }
    
    public static var token: String? {
        return shared.user?.idToken
    }
    
}

extension Auth {
    
    public class func update(_ user: AuthModel) {
        shared.user = user
        UserDefaults.standard.set(user, for: .authKey)
    }
    
    public class func clear() {
        shared.user = nil
        UserDefaults.standard.clear(.authKey)
    }
    
}
