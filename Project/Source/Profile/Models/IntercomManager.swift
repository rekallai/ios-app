//
//  IntercomManager.swift
//  Rekall
//
//  Created by Steve on 8/29/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Intercom

class IntercomManager: NSObject {
    static let shared = IntercomManager()
    private var user = UserViewModel.shared.user
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn(_:)), name: Notification.userLoggedIn , object: nil)
    }
    
    @objc func userLoggedIn(_ notification:Notification) {
        if let user = notification.userInfo?["user"] as? User {
            self.user = user
            registerInIntercom()
        }
    }
    
    func registerInIntercom(_ asUnidentified:Bool = false) {
        if ADApi.shared.store.isLoggedIn && user.id != "" {
            Intercom.registerUser(withUserId: user.id)
            let attrs = ICMUserAttributes()
            attrs.name = "\(user.firstName) \(user.lastName)"
            attrs.email = user.email
            Intercom.updateUser(attrs)
            if let userHash = user.intercomUserHash {
                Intercom.setUserHash(userHash)
            }
        } else if asUnidentified {
            Intercom.registerUnidentifiedUser()
        }
        registerPushIfAuthorized()
    }
    
    func configure(apiKey: String, appId: String) {
        Intercom.setApiKey(apiKey, forAppId: appId)
        registerInIntercom()
    }
    
    func launchMessenger() {
        registerInIntercom(true)
        Intercom.presentMessenger()
        checkPush()
    }
    
    func registerPushIfAuthorized() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func checkPush() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                self.requestPush()
            }
        }
    }
    
    func requestPush() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    static func setDeviceToken(_ token:Data) {
        Intercom.setDeviceToken(token)
    }
    
}
