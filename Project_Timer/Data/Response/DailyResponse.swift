//
//  DailyDTO.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/16.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation

struct DailyResponse: Decodable {
    var id: Int?
    var status: String?
    var day: Date
    var timeline: [Int]
    var maxTime: Int
    var tasks: [String: Int]
    var taskHistorys: [String: [TaskHistoryDTO]]?
}

struct TaskHistoryDTO: Decodable {
    var startDate: Date
    var endDate: Date
}

extension DailyResponse {
    func toDomain() -> Daily {
        return .init(
            id: self.id,
            status: self.status,
            day: self.day,
            timeline: self.timeline,
            maxTime: self.maxTime,
            tasks: self.tasks,
            taskHistorys: self.transHistorys())
    }
    
    func transHistorys() -> [String: [TaskHistory]]? {
        guard let taskHistorys = self.taskHistorys else { return nil }
        var trans: [String: [TaskHistory]] = [:]
        taskHistorys.forEach { task, historys in
            trans[task] = historys.map { $0.toDomain() }
        }
        return trans
    }
}

extension TaskHistoryDTO {
    func toDomain() -> TaskHistory {
        return .init(
            startDate: self.startDate,
            endDate: self.endDate)
    }
}
