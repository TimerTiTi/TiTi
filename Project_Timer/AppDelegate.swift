//
//  AppDelegate.swift
//  Project_Timer
//
//  Created by Min_MacBook Pro on 2020/06/08.
//  Copyright © 2020 FDEE. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /// 앱 실행시 Analytics 에 정보 전달부분
        FirebaseApp.configure()
        Analytics.logEvent("launch", parameters: [
            AnalyticsParameterItemID: "ver 7.2",
        ])
        /// Foreground 에서 알림설정을 활성화 하기 위한 delegate 연결 부분
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.addObserver(forName: .setBadge, object: nil, queue: .current) { _ in
            UIApplication.shared.applicationIconBadgeNumber = 1
        }
        NotificationCenter.default.addObserver(forName: .removeBadge, object: nil, queue: .current) { _ in
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        /// 앱 실행시 최신버전 체크로직 실행
        self.checkVersion()
        
        return true
    }
    
    /// 최신버전 체크로직
    private func checkVersion() {
        guard UserDefaultsManager.get(forKey: .updatePushable) as? Bool ?? true else { return }
        NetworkController(network: Network()).getAppstoreVersion { status, version in
            switch status {
            case .SUCCESS:
                guard let storeVersion = version else { return }
                print(String.currentVersion, storeVersion)
                
                if storeVersion.compare(String.currentVersion, options: .numeric) == .orderedDescending {
                    let message = "Please download the ".localized() + storeVersion + " version of the App Store :)".localized()
                    let alert = UIAlertController(title: "Update new version".localized(), message: message, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Not now", style: .default)
                    let update = UIAlertAction(title: "UPDATE", style: .default, handler: { _ in
                        if let url = URL(string: NetworkURL.appstore),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:])
                        }
                    })
                    
                    alert.addAction(ok)
                    alert.addAction(update)
                    SceneDelegate.sharedWindow?.rootViewController?.present(alert, animated: true)
                }
            default:
                return
            }
        }
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
}

/// Foreground 모드에서 notification 알림을 설정하기 위한 부분
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
