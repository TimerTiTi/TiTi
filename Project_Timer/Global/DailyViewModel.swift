//
//  DailyViewModel.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/06/29.
//  Copyright © 2021 FDEE. All rights reserved.
//

import Foundation

class DailyViewModel {
    
    private let manager = DailyManager.shared
    
    var dailys: [Daily] {
        return manager.dailys
    }
    
    var dates: [Date] {
        return manager.dates
    }
    
    func addDaily(_ daily: Daily) {
        manager.addDaily(daily)
    }
    
    func loadDailys() {
        manager.loadDailys()
    }
    
    func totalStudyTimeofMonth(month: Int, completion: @escaping (Int) -> ()) {
        let monthData = dailys.filter { $0.day.month == month }
        completion(monthData.reduce(0, { $0 + $1.totalTime }))
    }
    
    func totalStudyTimeOfMonth(completion: @escaping (Int) -> ()) {
        let yymm = Date().YYMMstyleInt
        completion(dailys.filter { $0.day.YYMMstyleInt == yymm }.reduce(0, { $0 + $1.totalTime }))
    }
}
