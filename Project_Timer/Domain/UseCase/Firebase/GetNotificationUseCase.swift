//
//  GetNotificationUseCase.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/07/07.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Combine

final class GetNotificationUseCase {
    private let repository: FirebaseRepository // TODO: 프로토콜로 수정
    
    init(repository: FirebaseRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<NotificationInfo?, NetworkError> {
        return self.repository.getNotification()
    }
}
