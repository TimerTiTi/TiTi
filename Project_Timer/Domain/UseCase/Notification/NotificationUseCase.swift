//
//  NotificationUseCase.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/27.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation

final class NotificationUseCase: NotificationUseCaseInterface {
    func isShowNotification() -> Bool {
        let signined = UserDefaultsManager.get(forKey: .signinInTestServerV1) as? Bool ?? false
        guard signined else { return false }
        
        let today = Date().YYYYMMDDstyleString
        if let passDay = UserDefaultsManager.get(forKey: .notificationPassDay) as? String {
            return today != passDay
        } else {
            return true
        }
    }
    
    func setPassDay() {
        let passDay = Date().YYYYMMDDstyleString
        UserDefaultsManager.set(to: passDay, forKey: .notificationPassDay)
    }
}
