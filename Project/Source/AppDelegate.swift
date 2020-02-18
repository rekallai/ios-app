//
//  AppDelegate.swift
//  Rekall
//
//  Created by Ray Hunter on 04/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Firebase
import Analytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if CommandLine.arguments.contains("--uitestingresetappstate") {
            Environment.resetAppState()
        }
        //dumpAllFonts()
        _ = Environment.shared  // Kick environment into life
        FirebaseApp.configure()
        UserViewModel.shared.loadUser()
        
        ADAnalytics.shared.track(event: "ADDidFinishLaunching")
                
        return true
    }
    
    func dumpAllFonts() {
        for familyName in UIFont.familyNames {
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print("\(fontName)")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // reload the data before return from background
        if let rootVC = application.keyWindow?.rootViewController as? RootViewController {
            rootVC.appWillEnterForeground()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        IntercomManager.setDeviceToken(deviceToken)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
