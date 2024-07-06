//
//  NotificationRepository.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/06/29.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Moya
import Combine
import CombineMoya

final class NotificationRepository {
    private let api: TTProvider<FirebaseAPI>
    
    init(api: TTProvider<FirebaseAPI>) {
        self.api = api
    }
    
    func get() -> AnyPublisher<NotificationInfo, NetworkError> {
        return self.api.request(.getNotification)
            .map(NotificationResponse.self)
            .map { $0.toDomain() }
            .catchDecodeError()
    }
}
