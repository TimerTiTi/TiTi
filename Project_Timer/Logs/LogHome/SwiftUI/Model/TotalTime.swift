//
//  TotalTime.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/09/06.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

struct TotalTime {
    let totalTime: Int
    let colorIndex: Int
    let reverseColor: Bool
    let top5Tasks: [TaskInfo]
    
    init(dailys: [Daily], isReverseColor: Bool) {
        var sumTotalTime: Int = 0
        var tasks: [String: Int] = [:]
        dailys.forEach { daily in
            sumTotalTime += daily.totalTime
            daily.tasks.forEach { key, value in
                if let sum = tasks[key] {
                    tasks[key] = sum + value
                } else {
                    tasks[key] = value
                }
            }
        }
        
        self.totalTime = sumTotalTime
        self.colorIndex = UserDefaultsManager.get(forKey: .startColor) as? Int ?? 1
        self.reverseColor = isReverseColor
        self.top5Tasks = Array(tasks.sorted { $0.value > $1.value }
            .map { TaskInfo(taskName: $0.key, taskTime: $0.value) }
            .prefix(5))
    }
}
