//
//  UserDefaultsManager.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/03/12.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

struct UserDefaultsManager {
    enum Keys: String {
        case isFirst = "isFirst"
        case VCNum = "VCNum"
        
        case timerPushable = "timerPushable"
        case stopwatchPushable = "stopwatchPushable"
        case restPushable = "restPushable"
        case updatePushable = "updatePushable"
        case timelabelsAnimation = "timelabelsAnimation"
        case flipToStartRecording = "flipToStartRecording"
        case keepTheScreenOn = "keepTheScreenOn"
        case startColor = "startColor"
        case checks = "checks"
        case didSaveToSharedContainerBefore = "savedToSharedContainerBefore"
    }
    
    static func set<T>(to: T, forKey: Self.Keys) {
        UserDefaults.standard.setValue(to, forKey: forKey.rawValue)
        print("UserDefaultsManager: save \(forKey) complete")
    }
    
    static func get(forKey: Self.Keys) -> Any? {
        return UserDefaults.standard.object(forKey: forKey.rawValue)
    }
}
