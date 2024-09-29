//
//  CheckUsernameExitUseCsae.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/07/06.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Combine

final class CheckUsernameExitUseCsae {
    private let repository: AuthRepository // TODO: 프로토콜로 수정
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute(request: CheckUsernameRequest) -> AnyPublisher<Bool, NetworkError> {
        return self.repository.checkUsernameExit(request: request)
    }
}
