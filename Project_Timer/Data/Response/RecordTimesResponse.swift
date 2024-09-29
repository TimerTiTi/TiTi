//
//  RecordTimesDTO.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/16.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation

struct RecordTimesResponse: Decodable {
    var recordingMode: Int
    var recording: Bool
    var recordStartAt: Date
    var updatedAt: Date
    var settedGoalTime: Int
    var settedTimerTime: Int
    var savedSumTime: Int
    var savedTimerTime: Int
    var savedStopwatchTime: Int
    var savedGoalTime: Int
    var recordTask: String
    var recordTaskFromTime: Int
    var recordStartTimeline: [Int]
}

extension RecordTimesResponse {
    func toDomain() -> RecordTimes {
        return .init(
            recordTask: self.recordTask,
            recordTaskFromTime: self.recordTaskFromTime,
            recordStartAt: self.recordStartAt,
            recording: self.recording,
            settedGoalTime: self.settedGoalTime,
            settedTimerTime: self.settedTimerTime,
            recordingMode: self.recordingMode,
            savedSumTime: self.savedSumTime,
            savedTimerTime: self.savedTimerTime,
            savedStopwatchTime: self.savedStopwatchTime,
            savedGoalTime: self.savedGoalTime,
            recordStartTimeline: self.recordStartTimeline)
    }
}
