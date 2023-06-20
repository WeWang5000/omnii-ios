//
//  AppDelegate.swift
//  omnii
//
//  Created by huyang on 2023/4/18.
//

import UIKit
import CommonUtils
import AuthenticationServices
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.applicationIconBadgeNumber = 0

        // init sendbird
        ChatManager.initSendbirdChat()
        
        // register push
        registerForPushNotifications()
        
        // init root vc
        initWindow()
        
        // apple id
        appleIDState()
        
        return true
    }
    
    private func initWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)

        if let _ = Auth.token {
            let mian = StartedViewController()
            window?.rootViewController = mian
        } else {
            let main = LoginViewController()
            window?.rootViewController = NavigationController(rootViewController: main)
        }
        
        window?.makeKeyAndVisible()
    }
    
    private func appleIDState() {
        guard let currentAppleUserIdentifier = KeychainItem.currentAppleUserIdentifier else { return }
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: currentAppleUserIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                // The Apple ID credential is valid.
                break
            case .revoked, .notFound:
                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                break
            default:
                break
            }
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        ChatManager.registerDevicePushToken(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
}
