//
//  SyncDailysVM.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/12/23.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation
import Combine

final class SyncDailysVM {
    private let getDailysUseCase: GetDailysUseCase
    private let postDailysUseCase: PostDailysUseCase
    private let getRecordTimeUseCase: GetRecordTimeUseCase
    private let postRecordTimeUseCase: PostRecordTimeUseCase
    private let getSyncLogUseCase: GetSyncLogUseCase
    private var targetDailys: [Daily]
    @Published private(set) var syncLog: SyncLog?
    @Published private(set) var alert: (title: String, text: String)?
    @Published private(set) var loading: Bool = false
    @Published private(set) var saveDailysSuccess: Bool = false
    private(set) var loadingText: SyncDailysVC.LoadingStatus?
    // Combine binding
    private var cancellables = Set<AnyCancellable>()
    
    init(getDailysUseCase: GetDailysUseCase,
         postDailysUseCase: PostDailysUseCase,
         getRecordTimeUseCase: GetRecordTimeUseCase,
         postRecordTimeUseCase: PostRecordTimeUseCase,
         getSyncLogUseCase: GetSyncLogUseCase,
        targetDailys: [Daily]) {
        self.getDailysUseCase = getDailysUseCase
        self.postDailysUseCase = postDailysUseCase
        self.targetDailys = targetDailys
        self.getRecordTimeUseCase = getRecordTimeUseCase
        self.postRecordTimeUseCase = postRecordTimeUseCase
        self.getSyncLogUseCase = getSyncLogUseCase
        
        self.checkServerURL()
    }
    
    private func checkServerURL() {
        NetworkURL.shared.getServerURL()
            .sink { [weak self] url in
                if url == nil {
                    self?.alert = (title: Localized.string(.Server_Popup_ServerCantUseTitle), text: Localized.string(.Server_Popup_ServerCantUseDesc))
                } else {
                    // fetch 서버 syncLog
                    self?.getSyncLog(afterUploaded: false)
                }
            }
            .store(in: &self.cancellables)
    }
}

extension SyncDailysVM {
    /// 동기화 버튼 클릭시 동기화 가능상태 확인 후 uploadDailys -> getDailys -> checkRecordTimes -> (uploadRecordTime or getRecordTime) -> getSyncLog 진행
    func checkSyncDailys() {
        guard NetworkURL.shared.serverURL != nil else {
            self.alert = (title: Localized.string(.Server_Popup_ServerCantUseTitle), text: Localized.string(.Server_Popup_ServerCantUseDesc))
            return
        }
        
        guard self.targetDailys.isEmpty == false else {
            // TODO: server date 값과 device date 값이 같은 경우 불필요 로직 필요
            self.getDailys()
            return
        }
        
        self.uploadDailys()
    }
    
    func updateTargetDailys(to dailys: [Daily]) {
        self.targetDailys = dailys
    }
}

// MARK: Upload
extension SyncDailysVM {
    /// uploadDailys -> getDailys 진행
    private func uploadDailys() {
        self.loadingText = .uploadDailys
        self.loading = true
        self.postDailysUseCase.execute(request: self.targetDailys)
            .sink { [weak self] completion in
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                    self?.loading = false
                    switch networkError {
                    case .CLIENTERROR(let message):
                        if let message = message {
                            print("[upload Dailys ERROR] \(message)")
                        }
                        self?.alert = (title: Localized.string(.Server_Error_UploadError), text: Localized.string(.Server_Error_DecodeError))
                    default:
                        self?.alert = networkError.alertMessage
                    }
                }
            } receiveValue: { [weak self] _ in
                self?.getDailys()
            }
            .store(in: &self.cancellables)
    }
    
    /// uploadRecordTime -> getSyncLog 진행
    private func uploadRecordTime() {
        let recordTimes = RecordsManager.shared.recordTimes
        self.loadingText = .uploadRecordTime
        self.loading = true
        self.postRecordTimeUseCase.execute(request: recordTimes)
            .sink { [weak self] completion in
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                    self?.loading = false
                    switch networkError {
                    case .CLIENTERROR(let message):
                        if let message = message {
                            print("[upload Recordtime ERROR] \(message)")
                        }
                        self?.alert = (title: Localized.string(.Server_Error_UploadError), text: Localized.string(.Server_Error_DecodeError))
                    default:
                        self?.alert = networkError.alertMessage
                    }
                }
            } receiveValue: { [weak self] _ in
                self?.loading = false
                self?.getSyncLog(afterUploaded: true)
            }
            .store(in: &self.cancellables)
    }
}

// MARK: Get
extension SyncDailysVM {
    /// getDailys -> checkRecordTimes 진행
    private func getDailys() {
        self.loadingText = .getDailys
        self.loading = true
        self.getDailysUseCase.execute()
            .sink { [weak self] completion in
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                    self?.loading = false
                    switch networkError {
                    case .CLIENTERROR(let message):
                        if let message = message {
                            print("[get Dailys ERROR] \(message)")
                        }
                        self?.alert = (title: Localized.string(.Server_Error_DownloadError), text: Localized.string(.Server_Error_DecodeError))
                    default:
                        self?.alert = networkError.alertMessage
                    }
                }
            } receiveValue: { [weak self] dailys in
                self?.saveDailys(dailys)
                self?.loading = false
                self?.checkRecordTimes()
            }
            .store(in: &self.cancellables)
    }
    
    /// getRecordTime -> getSyncLog 진행
    private func getRecordtime() {
        self.loadingText = .getRecordTime
        self.loading = true
        self.getRecordTimeUseCase.execute()
            .sink { [weak self] completion in
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                    self?.loading = false
                    switch networkError {
                    case .CLIENTERROR(let message):
                        if let message = message {
                            print("[get RecordTimes ERROR] \(message)")
                        }
                        self?.alert = (title: Localized.string(.Server_Error_DownloadError), text: Localized.string(.Server_Error_DecodeError))
                    default:
                        self?.alert = networkError.alertMessage
                    }
                }
            } receiveValue: { [weak self] recordTimes in
                self?.saveRecordTimes(recordTimes)
                self?.loading = false
                self?.getSyncLog(afterUploaded: true)
            }
            .store(in: &self.cancellables)
    }
    
    /// sync 로직 후 getSyncLog, 또는 화면진입시 진행
    private func getSyncLog(afterUploaded: Bool) {
        self.loadingText = .getSyncLog
        self.loading = true
        self.getSyncLogUseCase.execute()
            .sink { [weak self] completion in
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                    self?.loading = false
                    switch networkError {
                    case .CLIENTERROR(let message):
                        if let message = message {
                            print("[get SyncLog ERROR] \(message)")
                        }
                        self?.alert = (title: Localized.string(.Server_Error_DownloadError), text: Localized.string(.Server_Error_DecodeError))
                    default:
                        self?.alert = networkError.alertMessage
                    }
                }
            } receiveValue: { [weak self] syncLog in
                self?.loading = false
                if afterUploaded {
                    self?.saveLastUploadedDate(to: syncLog.updatedAt)
                    self?.targetDailys = []
                    self?.saveDailysSuccess = true
                }
                self?.syncLog = syncLog
            }
            .store(in: &self.cancellables)
    }
}

// MARK: Save
extension SyncDailysVM {
    private func saveDailys(_ dailys: [Daily]) {
        // dailys 저장
        RecordsManager.shared.dailyManager.changeDailys(to: dailys)
        
        if let daily = RecordsManager.shared.dailyManager.dailys.last {
            RecordsManager.shared.currentDaily = daily
            RecordsManager.shared.currentDaily.save()
        }
    }
    
    private func saveRecordTimes(_ recordtimes: RecordTimes) {
        // TODO: 상단 날짜가 이상한점 확인 필요
        RecordsManager.shared.recordTimes = recordtimes
        RecordsManager.shared.recordTimes.save()
    }
    
    private func saveLastUploadedDate(to date: Date) {
        UserDefaultsManager.set(to: date, forKey: .lastUploadedDateV1)
    }
}

// MARK: Check
extension SyncDailysVM {
    private func checkRecordTimes() {
        guard let lastDaily = RecordsManager.shared.dailyManager.dailys.last,
              let dailyStartAt = lastDaily.taskHistorys?.values
            .flatMap({ $0 })
            .sorted(by: { $0.endDate < $1.endDate })
            .last?.startDate else {
            // 정보가 없는 경우
            self.getSyncLog(afterUploaded: true)
            return
        }
        
        let localStartAt = RecordsManager.shared.recordTimes.recordStartAt
        
        if (dailyStartAt.YYYYMMDDHMSstyleString == localStartAt.YYYYMMDDHMSstyleString) {
            self.uploadRecordTime()
        } else {
            self.getRecordtime()
        }
    }
}
