//
//  FirebaseRepository.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/05/15.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Moya
import Combine
import CombineMoya

final class FirebaseRepository {
    private let api: TTProvider<FirebaseAPI>
    
    init(api: TTProvider<FirebaseAPI>) {
        self.api = api
    }
    
    func getAppVersion() -> AnyPublisher<AppLatestVersionInfo, NetworkError> {
        return self.api.request(.getAppVersion)
            .map(AppVersionResponse.self)
            .map { $0.toDomain() }
            .catchDecodeError()
    }
    
    func getServerURL() -> AnyPublisher<String, NetworkError> {
        return self.api.request(.getServerURL)
            .map(ServerURLResponse.self)
            .map { $0.base.value }
            .catchDecodeError()
    }
    
    func getTiTiFunctions() -> AnyPublisher<[FunctionInfo], NetworkError> {
        return self.api.request(.getTiTiFunctions)
            .map(FunctionResponse.self)
            .map { $0.functionInfos }
            .catchDecodeError()
    }
    
    func getUpdateHistorys() -> AnyPublisher<[UpdateHistoryInfo], NetworkError> {
        return self.api.request(.getUpdateHistorys)
            .map(UpdateHistoryResponse.self)
            .map { $0.updateInfos }
            .catchDecodeError()
    }
    
    func getYoutubeLink() -> AnyPublisher<String, NetworkError> {
        return self.api.request(.getYoutubeLink)
            .map(YoutubeLinkResponse.self)
            .map { $0.url.value }
            .catchDecodeError()
    }
    
    func getSurveys() -> AnyPublisher<[SurveyInfo], NetworkError> {
        return self.api.request(.getSurveys)
            .map(SurveyResponse.self)
            .map { $0.surveyInfos ?? [] }
            .catchDecodeError()
    }
    
    func getNotification() -> AnyPublisher<NotificationInfo?, NetworkError> {
        return self.api.request(.getNotification)
            .map(NotificationResponse.self)
            .map { $0.visible.value == true ? $0.toDomain() : nil }
            .catchDecodeError()
    }
}
