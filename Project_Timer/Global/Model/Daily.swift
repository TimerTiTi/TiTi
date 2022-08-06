//
//  Daily.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/04/06.
//  Copyright © 2021 FDEE. All rights reserved.
//

import Foundation

struct TaskHistory: Codable {
    let startDate: Date
    let endDate: Date
}

struct Daily: Codable, CustomStringConvertible {
    var description: String {
        return "\(self.day.YYYYMMDDstyleString) : \(self.tasks)"
    }
    static let fileName: String = "daily.json"
    private(set) var day: Date = Date() // 기록 날짜값
    private(set) var tasks: [String: Int] = [:] // 과목명-누적시간 값
    private(set) var maxTime: Int = 0 // 최고 연속시간
    private(set) var timeline = Array(repeating: 0, count: 24) // 시간대별 그래프값, (24시: 0)
    var totalTime: Int { // computed property
        return self.tasks.values.reduce(0, +)
    }
    private(set) var taskHistorys: [String: [TaskHistory]]? = [:]
    
    // 10간격, 또는 종료시 update 반영
    mutating func update(at current: Date) {
        let recordTimes = RecordController.shared.recordTimes
        // 기존 과거형식의 기록, 또는 기록중인 상태의 경우 -> 기존 update 로직을 통해 Daily 값을 update 한다
        if self.taskHistorys == nil {
            let interval = Date.interval(from: recordTimes.recordStartAt, to: current)
            self.tasks[recordTimes.recordTask] = recordTimes.recordTaskFromTime + interval
            self.maxTime = max(self.maxTime, interval)
            self.updateTimeline(recordTimes: recordTimes, interval: interval, current: current)
        }
        // 업데이트 후 새로운 기록 이후 taskHistorys 가 nil 값이 아닌 상태의 경우 -> taskHistorys 를 기반으로 Daily 값을 update 한다
        else {
            self.updateTaskHistorys(taskName: recordTimes.recordTask, startDate: recordTimes.recordStartAt, endDate: current)
            self.updateTasks()
            self.updateMaxTime()
            self.updateTimeline()
        }
        self.save()
    }
    
    private mutating func updateTimeline(recordTimes: RecordTimes, interval: Int, current: Date) {
        let startHour = recordTimes.recordStartAt.hour
        let nowHour = current.hour < startHour ? current.hour+24 : current.hour
        // 동일 시간대: interval 만큼 증가
        if startHour == nowHour {
            self.timeline[nowHour] = recordTimes.recordStartTimeline[nowHour] + interval
            self.save()
            return
        }
        
        self.timeline[startHour] = recordTimes.recordStartTimeline[startHour] + (3600 - self.getSecondsAt(recordTimes.recordStartAt))
        self.timeline[startHour] = min(3600, self.timeline[startHour])
        
        for h in startHour+1...nowHour {
            if h != nowHour {
                self.timeline[h%24] = 3600
            } else {
                self.timeline[h%24] = self.getSecondsAt(current)
            }
        }
    }
    // 기존 tasks 정보 수정시
    mutating func updateTasks(to newTasks: [String: Int]) {
        self.tasks = newTasks
        self.save()
    }
    
    // 새로운 날짜의 기록 시작시 reset
    mutating func reset() {
        self = Daily()
        self.save()
    }
    
    func save() {
        Storage.store(self, to: .documents, as: Daily.fileName)
    }
    
    mutating func load() {
        self = Storage.retrive(Daily.fileName, from: .documents, as: Daily.self) ?? Daily()
    }
    
    private func getSecondsAt(_ date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        let M = Int(dateFormatter.string(from: date))! //분
        dateFormatter.dateFormat = "ss"
        let S = Int(dateFormatter.string(from: date))! //초
        return M*60+S
    }
}

// MARK: 새로운 기록저장 로직
extension Daily {
    private mutating func updateTaskHistorys(taskName: String, startDate: Date, endDate: Date) {
        if var taskHistorys = self.taskHistorys {
            // file 내 값이 존재했으며, 해당과목의 이전 정보가 있는 경우
            if var targetHistory = taskHistorys[taskName] {
                targetHistory.append(TaskHistory(startDate: startDate, endDate: endDate))
                taskHistorys[taskName] = targetHistory
                self.taskHistorys = taskHistorys
            }
            // file 내 값이 존재했으며, 해당과목의 기록이 없었던 경우
            else {
                taskHistorys[taskName] = [TaskHistory(startDate: startDate, endDate: endDate)]
                self.taskHistorys = taskHistorys
            }
        } else {
            assertionFailure("taskHistorys 값이 nil 입니다.")
        }
    }
    
    private mutating func updateTasks() {
        guard let taskHistorys = self.taskHistorys else { return }
        var tasks: [String: Int] = [:]
        taskHistorys.forEach { task, historys in
            tasks[task] = historys.map { Date.interval(from: $0.startDate, to: $0.endDate) }.reduce(0, +)
        }
        self.tasks = tasks
    }
    
    private mutating func updateMaxTime() {
        guard let taskHistorys = self.taskHistorys else { return }
        var maxTime: Int = 0
        taskHistorys.forEach { task, historys in
            if historys.isEmpty == false {
                maxTime = max(maxTime, historys.map { Date.interval(from: $0.startDate, to: $0.endDate) }.max()!)
            }
        }
        self.maxTime = maxTime
    }
    
    private mutating func updateTimeline() {
        guard let taskHistorys = self.taskHistorys else { return }
        var timeline = Array(repeating: 0, count: 24)
        taskHistorys.forEach { _, historys in
            historys.forEach { history in
                let startHour = history.startDate.hour
                var endHour = history.endDate.hour
                endHour = endHour < startHour ? endHour+24 : endHour
                
                if startHour == endHour {
                    timeline[startHour] += Date.interval(from: history.startDate, to: history.endDate)
                } else {
                    timeline[startHour] += (3600 - self.getSecondsAt(history.startDate))
                    for h in startHour+1...endHour {
                        if h != endHour {
                            timeline[h%24] = 3600
                        } else {
                            timeline[h%24] = self.getSecondsAt(history.endDate)
                        }
                    }
                }
            }
        }
        for i in 0...23 { timeline[i] = min(3600, timeline[i]) }
        self.timeline = timeline
    }
}
