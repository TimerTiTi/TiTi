//
//  AppDelegate.swift
//  Project_Timer
//
//  Created by Min_MacBook Pro on 2020/06/08.
//  Copyright © 2020 FDEE. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAnalytics
import GoogleMobileAds
import WidgetKit
import GoogleSignIn
import Moya
import Combine

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    static var shared: AppDelegate {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate
    }
    // 화면 회전을 제어할 변수 선언
    var shouldSupportPortraitOrientation = false
    // Combine binding
    private var cancellables = Set<AnyCancellable>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.checkLatestVersion(isLaunch: true)
        self.checkGoogleSignOut()
        
        if Infos.isDevMode == false {
            self.configureGoogleAdmob()
        }
        
        self.updateToLastestVersion()
        self.configureNotificationCenterAddObserver()
        self.configureMacCatalyst()
        self.configureWidget()
        
        self.checkSignined()
        self.checkNotification()
        
        return true
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
    
    // MARK: Contigure Rotation
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if shouldSupportPortraitOrientation {
            return .portrait
        } else {
            return .all
        }
    }
    
    // MARK: Redirection
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        // Handle other custom URL types.
        
        // If not handled by this app, return false.
        return false
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

// MARK: Configure
extension AppDelegate {
    /// 최신버전 체크
    private func checkLatestVersion(isLaunch: Bool) {
        // TODO: DI 수정
        let api = TTProvider<FirebaseAPI>(session: Session(interceptor: NetworkInterceptor.shared))
        let repository = FirebaseRepository(api: api)
        let getAppVersionUseCase = GetAppVersionUseCase(repository: repository)
        
        getAppVersionUseCase.execute()
            .sink { completion in
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                }
            } receiveValue: { [weak self] appLatestVersionInfo in
                let storeVersion = appLatestVersionInfo.latestVersion
                guard storeVersion.compare(String.currentVersion, options: .numeric) == .orderedDescending else { return }
                
                if appLatestVersionInfo.forced == true {
                    // MARK: 강제 업데이트 필요 Alert 표시
                    let title = Localized.string(.Update_Popup_HardUpdateTitle)
                    let text = Localized.string(.Update_Popup_HardUpdateDesc)
                    let ok = UIAlertAction(title: Localized.string(.Common_Text_OK), style: .default) { _ in
                        if let url = URL(string: NetworkURL.appstore),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:])
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                exit(0)
                            }
                        }
                    }
                    self?.showAlert(title: title, text: text, actions: [ok])
                } else if isLaunch == true && UserDefaultsManager.get(forKey: .updatePushable) as? Bool ?? true {
                    // MARK: 업데이트 Alert 표시
                    let title = Localized.string(.Update_Pupup_SoftUpdateTitle)
                    let text = Localized.string(.Update_Popup_SoftUpdateDesc, op: storeVersion)
                    
                    let pass = UIAlertAction(title: Localized.string(.Update_Popup_NotNow), style: .default)
                    let update = UIAlertAction(title: Localized.string(.Update_Popup_Update), style: .default) { _ in
                        if let url = URL(string: NetworkURL.appstore),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:])
                        }
                    }
                    self?.showAlert(title: title, text: text, actions: [pass, update])
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func showAlert(title: String, text: String?, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        actions.forEach { action in
            alert.addAction(action)
        }
        SceneDelegate.sharedWindow?.rootViewController?.present(alert, animated: true)
    }
    
    private func checkGoogleSignOut() {
        /// 사용자의 로그인 상태 복원 시도
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // MARK: SignOut 구현
                GIDSignIn.sharedInstance.signOut()
            } else {
                // MARK: SignIn 관련 로직 필요한지 확인 필요
            }
        }
    }
    
    private func configureGoogleAdmob() {
        /// 애드몹 이니셜라이즈
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        // MARK: 릴리즈할 때 해당 부분 제거!!!!!!
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "4d05e46e5ab0994dee203a9e0477ddaf" ]
        
        /// 앱 실행시 Analytics 에 정보 전달부분
        FirebaseApp.configure()
        Analytics.logEvent("launch", parameters: [
            AnalyticsParameterItemID: "ver \(String.currentVersion)",
        ])
    }
    
    private func configureNotificationCenterAddObserver() {
        /// Foreground 에서 알림설정을 활성화 하기 위한 delegate 연결 부분
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.addObserver(forName: .setBadge, object: nil, queue: .current) { _ in
            UIApplication.shared.applicationIconBadgeNumber = 1
        }
        NotificationCenter.default.addObserver(forName: .removeBadge, object: nil, queue: .current) { _ in
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .current) { [weak self] _ in
            self?.checkLatestVersion(isLaunch: false)
        }
    }
    
    private func configureMacCatalyst() {
        /// Mac 의 경우 Control 옵션 비활성화
        #if targetEnvironment(macCatalyst)
        UserDefaultsManager.set(to: false, forKey: .keepTheScreenOn)
        UserDefaultsManager.set(to: false, forKey: .flipToStartRecording)
        #endif
    }
    
    private func configureWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "CalendarWidget")
    }
    
    private func checkSignined() {
        /// signout 상태의 경우 KeyChain 초기화
        let signined = UserDefaultsManager.get(forKey: .signinInTestServerV1) as? Bool ?? false
        if signined == false {
            guard KeyChain.shared.deleteAll() else {
                print("ERROR: KeyChain.shared.deleteAll"); print()
                return
            }
        }
    }
    
    private func checkNotification() {
        // TODO: DI 수정
        let api = TTProvider<FirebaseAPI>(session: Session(interceptor: NetworkInterceptor.shared))
        let repository = FirebaseRepository(api: api)
        let getNotificationUseCase = GetNotificationUseCase(repository: repository)
        let notificationUseCase = NotificationUseCase()
        
        getNotificationUseCase.execute()
            .sink { completion in
                    if case .failure(let networkError) = completion {
                        print("ERROR", #function, networkError)
                    }
            } receiveValue: { notificationInfo in
                guard let notificationInfo = notificationInfo else { return }
                guard notificationUseCase.isShowNotification() else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let notificationVC = NotificationVC(noti: notificationInfo, notificationUseCase: notificationUseCase)
                    SceneDelegate.sharedWindow?.rootViewController?.present(notificationVC, animated: true)
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func updateToLastestVersion() {
        Versions.update()
    }
}
