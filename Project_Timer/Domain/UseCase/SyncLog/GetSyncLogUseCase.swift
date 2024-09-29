//
//  GetSyncLogUseCase.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/07/07.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Combine

final class GetSyncLogUseCase {
    private let repository: SyncLogRepository // TODO: 프로토콜로 수정
    
    init(repository: SyncLogRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<SyncLog, NetworkError> {
        return self.repository.get()
    }
}
