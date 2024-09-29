//
//  SyncLogRepository.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/06/29.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Moya
import Combine
import CombineMoya

final class SyncLogRepository {
    private let api: TTProvider<DailysAPI>
    
    init(api: TTProvider<DailysAPI>) {
        self.api = api
    }
    
    func get() -> AnyPublisher<SyncLog, NetworkError> {
        return self.api.request(.getSyncLog)
            .map(SyncLogResponse.self)
            .map { $0.toDomain() }
            .catchDecodeError()
    }
}
