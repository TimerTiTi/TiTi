//
//  SyncDailysVM.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/12/23.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation
import Combine

typealias DailysSyncable = (TestServerSyncLogFetchable & TestServerDailyFetchable & TestServerRecordTimesFetchable)

final class SyncDailysVM {
    private let networkController: DailysSyncable
    private var targetDailys: [Daily]
    @Published private(set) var syncLog: SyncLog?
    @Published private(set) var error: (title: String, text: String)?
    @Published private(set) var loading: Bool = false
    @Published private(set) var saveDailysSuccess: Bool = false
    private(set) var loadingText: SyncDailysVC.LoadingStatus?
    
    init(networkController: DailysSyncable, targetDailys: [Daily]) {
        self.networkController = networkController
        self.targetDailys = targetDailys
        
        self.getUserDailysInfo(isUploaded: false)
    }
}

extension SyncDailysVM {
    func checkSyncDailys() {
        guard self.targetDailys.isEmpty == false else {
            self.getDailys()
            return
        }
        
        self.uploadDailys()
    }
}

extension SyncDailysVM {
    private func getUserDailysInfo(isUploaded: Bool) {
        self.loadingText = .getSyncLog
        self.loading = true
        self.networkController.getSyncLog { [weak self] status, syncLog in
            switch status {
            case .SUCCESS:
                guard let syncLog = syncLog else {
                    self?.error = ("Network Error", "get userDailysInfo Error")
                    return
                }
                if (isUploaded) {
                    self?.saveLastUploadedDate(to: syncLog.updatedAt)
                }
                self?.loading = false
                self?.syncLog = syncLog
            case .DECODEERROR:
                self?.error = ("Decode Error", "Decode UserDailysInfo Error")
            default:
                self?.error = ("Network Error", "status: \(status.rawValue)")
            }
        }
    }
    
    private func uploadDailys() {
        self.loadingText = .uploadDailys
        self.loading = true
        self.networkController.uploadDailys(dailys: self.targetDailys) { [weak self] status in
            switch status {
            case .SUCCESS:
                self?.loading = false
                self?.getDailys()
            default:
                self?.loading = false
                self?.error = ("Network Error", "status: \(status.rawValue)")
            }
        }
    }
    
    private func getDailys() {
        self.loadingText = .getDailys
        self.loading = true
        self.networkController.getDailys { [weak self] status, dailys in
            switch status {
            case .SUCCESS:
                guard dailys.isEmpty == false else {
                    self?.loading = false
                    self?.error = ("Empty Dailys", "Check the Server's Dailys count")
                    return
                }
                
                self?.store(dailys)
                self?.loading = false
                self?.getUserDailysInfo(isUploaded: true)
            case .DECODEERROR:
                self?.loading = false
                self?.error = ("Decode Error", "Decode Dailys Error")
            default:
                self?.loading = false
                self?.error = ("Network Error", "status: \(status.rawValue)")
            }
        }
    }
}

extension SyncDailysVM {
    private func store(_ dailys: [Daily]) {
        // dailys 저장
        RecordController.shared.dailys.changeDailys(to: dailys)
        self.saveDailysSuccess = true
    }
    
    private func saveLastUploadedDate(to date: Date) {
        UserDefaultsManager.set(to: date, forKey: .lastUploadedDateV1)
    }
}
