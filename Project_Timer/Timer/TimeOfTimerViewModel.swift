//
//  TimeOfTimerViewModel.swift
//  Project_Timer
//
//  Created by 최수정 on 2022/06/27.
//  Copyright © 2022 FDEE. All rights reserved.
//

import SwiftUI

class TimeOfTimerViewModel: ObservableObject {
    enum TimerState {
        case normalRunning
        case lessThan60Sec
        case stopped
    }
    
    var timeLabelViewModel: TimeLabelViewModel
    @Published var isRunning: Bool = false
    @Published var time: Int {
        didSet {
            self.timeLabelViewModel.updateTime(time)
        }
    }
    
    var finished: Bool {
        self.time == 0
    }
    var timerState: TimerState {
        if isRunning {
            return self.time < 60 ? .lessThan60Sec : .normalRunning
        } else {
            return .stopped
        }
    }
    
    init(time: Int, showAnimation: Bool) {
        self.time = time
        self.timeLabelViewModel = TimeLabelViewModel(time: time, showAnimation: showAnimation)
    }
    
    func updateTime(_ newTime: Int) {
        self.time = newTime
    }
}
