//
//  TimerVM.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/05/04.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation
import Combine
import UserNotifications

final class TimerVM {
    @Published private(set) var times: Times
    @Published private(set) var daily: Daily
    @Published private(set) var task: String
    @Published private(set) var runningUI = false
    @Published private(set) var soundAlert = false
    @Published private(set) var warningNewDate = false
    private(set) var timerRunning = false {
        didSet {
            self.timeOfTimerViewModel.isRunning = timerRunning
        }
    }
    private var timerCount: Int = 0
    private let userNotificationCenter = UNUserNotificationCenter.current()
    
    private var timer = Timer()
    
    let timeOfTimerViewModel: TimeOfTimerViewModel
    let timeOfSumViewModel: TimeLabelViewModel
    let timeOfTargetViewModel: TimeLabelViewModel
    
    init() {
        let currentTimes = RecordController.shared.recordTimes.currentTimes()
        self.times = currentTimes
        self.daily = RecordController.shared.daily
        self.task = RecordController.shared.recordTimes.recordTask
        self.timeOfTimerViewModel = TimeOfTimerViewModel(time: currentTimes.timer)
        self.timeOfSumViewModel = TimeLabelViewModel(time: currentTimes.sum, updateType: .countUp)
        self.timeOfTargetViewModel = TimeLabelViewModel(time: currentTimes.goal, updateType: .countDown)
        self.requestNotificationAuthorization()
        self.soundAlert = false
        
        if RecordController.shared.recordTimes.recording {
            print("automatic start")
            self.timerStart()
        } else {
            self.checkRecordDate()
        }
    }
    
    private func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    private func checkRecordDate() {
        self.warningNewDate = RecordController.shared.showWarningOfRecordDate
    }
    
    var settedTimerTime: Int {
        return RecordController.shared.recordTimes.settedTimerTime
    }
    
    var settedGoalTime: Int {
        return RecordController.shared.recordTimes.settedGoalTime
    }
    
    func updateTimes() {
        self.times = RecordController.shared.recordTimes.currentTimes()
        // TODO: showsAnimation 여부를 UserDefault에서 가져오도록
        self.timeOfTimerViewModel.updateTime(self.times.timer, showsAnimation: true)
        self.timeOfSumViewModel.updateTime(self.times.sum, showsAnimation: true)
        self.timeOfTargetViewModel.updateTime(self.times.goal, showsAnimation: true)
    }
    
    func updateDaily() {
        self.daily = RecordController.shared.daily
    }
    
    func updateTask() {
        self.task = RecordController.shared.recordTimes.recordTask
    }
    
    func updateModeNum() {
        UserDefaultsManager.set(to: 1, forKey: .VCNum)
        RecordController.shared.recordTimes.updateMode(to: 1)
    }
    
    func changeTask(to task: String) {
        self.task = task
        let taskTime = RecordController.shared.daily.tasks[task] ?? 0
        RecordController.shared.recordTimes.updateTask(to: task, fromTime: taskTime)
        self.updateTimes()
    }
    
    func timerAction() {
        if self.timerRunning {
            self.timerStop()
            self.removeBadge()
            self.removeNotification()
        } else {
            RecordController.shared.recordTimes.recordStart()
            self.checkTimerReset()
            self.timerStart()
            self.setBadge()
            self.sendNotification()
        }
    }
    
    func timerReset() {
        RecordController.shared.recordTimes.resetTimer()
        self.times = RecordController.shared.recordTimes.currentTimes()
        self.timeOfTimerViewModel.updateTime(self.times.timer, showsAnimation: false)
        self.timeOfSumViewModel.updateTime(self.times.sum, showsAnimation: false)
        self.timeOfTargetViewModel.updateTime(self.times.goal, showsAnimation: false)
    }
    
    func updateTimerTime(to timer: Int) {
        RecordController.shared.recordTimes.updateTimerTime(to: timer)
        self.updateTimes()
    }
    
    func newRecord() {
        RecordController.shared.daily.reset()
        RecordController.shared.recordTimes.reset()
        self.updateDaily()
        self.updateTimes()
    }
    
    private func checkTimerReset() {
        guard self.times.timer <= 0 else { return }
        self.timerReset()
    }
    
    private func timerStart() {
        // timer 동작, runningUI 반영
        guard self.timerRunning == false else { return }
        print("timer start")
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerLogic), userInfo: nil, repeats: true)
        self.timerRunning = true
        self.runningUI = true
        self.soundAlert = false
    }
    
    @objc func timerLogic() {
        print("timer action")
        self.timerCount += 1
        self.updateTimes()
        if self.timerCount%5 == 0 {
            RecordController.shared.daily.update(at: Date())
        }
        
        if self.times.timer < 1 {
            self.timerStop()
            self.removeBadge()
            self.removeNotification()
        }
    }
    
    private func setBadge() {
        NotificationCenter.default.post(name: .setBadge, object: nil)
    }
    
    private func removeBadge() {
        NotificationCenter.default.post(name: .removeBadge, object: nil)
    }
    
    private func timerStop() {
        print("timer stop")
        self.timer.invalidate()
        self.timerRunning = false
        self.runningUI = false
        self.timerCount = 0
        self.soundAlert = true
        let endAt = Date()
        RecordController.shared.daily.update(at: endAt)
        self.updateDaily()
        RecordController.shared.recordTimes.recordStop(finishAt: endAt, taskTime: self.daily.tasks[self.task] ?? 0)
        RecordController.shared.dailys.addDaily(self.daily)
    }
    
    func enterBackground() {
        print("background")
        self.timer.invalidate()
        self.timerRunning = false
    }
    
    func enterForground() {
        print("forground")
        self.timerStart()
        self.timerLogic()
    }
    
    private func sendNotification() {
        guard UserDefaultsManager.get(forKey: .timerPushable) as? Bool ?? true else { return }
        let remainTimer = self.times.timer
        let alarm_5m = remainTimer - 300
        self.postNoti(interval: remainTimer, body: "Timer finished!".localized(), identifier: "Timer finished")
        if alarm_5m >= 0 {
            self.postNoti(interval: alarm_5m, body: "5 minutes left".localized(), identifier: "Timer 5 min")
        }
    }
    
    private func postNoti(interval: Int, body: String, identifier: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Timer".localized()
        notificationContent.body = body
        notificationContent.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(interval), repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        self.userNotificationCenter.add(request) { error in
            if let error = error {
                print("Notification Error: \(error)")
            }
        }
    }
    
    private func removeNotification() {
        self.userNotificationCenter.removeAllPendingNotificationRequests()
    }
}