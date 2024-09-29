//
//  PostSignupUseCase.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/07/06.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Combine

final class SignupUseCase {
    private let repository: AuthRepository // TODO: 프로토콜로 수정
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute(request: TestUserSignupRequest) -> AnyPublisher<AuthInfo, NetworkError> {
        return self.repository.signup(request: request)
    }
}
