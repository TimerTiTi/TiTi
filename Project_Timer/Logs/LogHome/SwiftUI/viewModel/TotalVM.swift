//
//  TotalVM.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/09/06.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

final class TotalVM: ObservableObject {
    @Published var totalTime: Int = 0
    @Published var colorIndex: Int = 1
    @Published var reverseColor: Bool = false
    @Published var top5Tasks: [TaskInfo] = []
    
    init() {
        self.updateColor(isReverseColor: false)
    }
    
    func update(totalTime: TotalTime, reverseColor: Bool = false) {
        self.totalTime = totalTime.totalTime
        self.colorIndex = totalTime.colorIndex
        self.top5Tasks = totalTime.top5Tasks
        self.updateColor(isReverseColor: reverseColor)
    }
    
    func updateColor(isReverseColor: Bool) {
        self.colorIndex = UserDefaultsManager.get(forKey: .startColor) as? Int ?? 1
        self.reverseColor = isReverseColor
    }
}
