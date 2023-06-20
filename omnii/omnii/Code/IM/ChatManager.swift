//
//  ChatManager.swift
//  omnii
//
//  Created by huyang on 2023/6/16.
//

import Foundation
import SendbirdChatSDK

final class ChatManager {
    
    static var unique: Bool {
        return true
    }
    
    class func initSendbirdChat() {
        let initParams = InitParams(
            applicationId: "F2897800-27CF-4EF4-8E84-F4408185B1CC",
            isLocalCachingEnabled: true,
            logLevel: .error
        )
        
        SendbirdChat.initialize(params: initParams)
    }
    
    class func registerDevicePushToken(deviceToken: Data) {
        
        guard let _ = Auth.userId else { return }

        SendbirdChat.registerDevicePushToken(deviceToken, unique: unique) { status, error in

            // A device token is successfully registered.
            guard let _ = error else { return }

            // Handle registration failure.
            guard status == PushTokenRegistrationStatus.pending else { return }

            if let token = SendbirdChat.getPendingPushToken() {
                SendbirdChat.registerDevicePushToken(token, unique: unique)
            }

        }
        
    }
    
    class func connectSendbirdChat() {
        
        guard let userId = Auth.userId else { return }
        
        if SendbirdChat.getConnectState() == .connecting { return }
        
        SendbirdChat.connect(userId: userId) { user, error in
            
            // Handle error.
            guard let _ = user, error == nil else { return }

            if let token = SendbirdChat.getPendingPushToken() {
                SendbirdChat.registerDevicePushToken(token, unique: unique)
            }
            
        }
        
    }
    
}
