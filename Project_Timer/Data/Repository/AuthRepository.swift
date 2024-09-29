//
//  AuthRepository.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/05/22.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Moya
import Combine
import CombineMoya

final class AuthRepository {
    private let api: TTProvider<AuthAPI>
    
    init(api: TTProvider<AuthAPI>) {
        self.api = api
    }
    
    func signup(request: TestUserSignupRequest) -> AnyPublisher<AuthInfo, NetworkError> {
        return self.api.request(.postSignup(request))
            .map(AuthResponse.self)
            .map { $0.toDomain() }
            .catchDecodeError()
    }
    
    func signin(request: TestUserSigninRequest) -> AnyPublisher<AuthInfo, NetworkError> {
        return self.api.request(.postSignin(request))
            .map(AuthResponse.self)
            .map { $0.toDomain() }
            .catchDecodeError()
    }
    
    func checkUsernameExit(request: CheckUsernameRequest) -> AnyPublisher<Bool, NetworkError> {
        return self.api.request(.getCheckUsername(request))
            .map(SimpleResponse.self)
            .map { $0.toDomain() }
            .catchDecodeError()
    }
    
    func checkEmailExit(request: CheckEmailExitRequest) -> AnyPublisher<Bool, NetworkError> {
        return self.api.request(.getCheckEmail(request))
            .map(SimpleResponse.self)
            .map { $0.toDomain() }
            .catchDecodeError()
    }
    
    func updatePassword(request: UpdatePasswordRequest) -> AnyPublisher<Bool, NetworkError> {
        return self.api.request(.postUpdatePassword(request))
            .map(SimpleResponse.self)
            .map { $0.toDomain() }
            .catchDecodeError()
    }
}
