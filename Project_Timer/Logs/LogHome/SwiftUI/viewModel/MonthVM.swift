//
//  MonthVM.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/09/10.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

final class MonthVM: ObservableObject {
    @Published var totalTime: Int = 0
    @Published var colorIndex: Int = 1
    @Published var reverseColor: Bool = false
    @Published var top5Tasks: [TaskInfo] = []
    
    init() {
        self.updateColor()
    }
    
    func update(monthTime: MonthTime) {
        self.totalTime = monthTime.totalTime
        self.colorIndex = monthTime.colorIndex
        self.top5Tasks = monthTime.top5Tasks
        self.updateColor()
    }
    
    func updateColor() {
        self.colorIndex = UserDefaultsManager.get(forKey: .startColor) as? Int ?? 1
        self.reverseColor = UserDefaultsManager.get(forKey: .reverseColor) as? Bool ?? false
    }
}
