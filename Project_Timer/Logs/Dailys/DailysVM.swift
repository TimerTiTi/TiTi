//
//  DailysVM.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/07/24.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

final class DailysVM {
    /* public */
    @Published private(set) var currentDaily: Daily?
    @Published private(set) var tasks: [TaskInfo] = []
    let timelineVM: TimelineVM
    
    init() {
        self.timelineVM = TimelineVM()
    }
    
    func updateDaily(to daily: Daily?) {
        dump(daily)
        self.currentDaily = daily
        self.timelineVM.update(daily: daily)
        guard let tasks = daily?.tasks else {
            self.tasks = []
            return
        }
        self.tasks = tasks.sorted(by: { $0.value > $1.value })
            .map { TaskInfo(taskName: $0.key, taskTime: $0.value) }
    }
    
    func updateColor(isReverseColor: Bool) {
        self.timelineVM.updateColor(isReversColor: isReverseColor)
    }
}
