//
//  AuthRepositoryInterface.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/15.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation

protocol AuthRepositoryInterface {
    func signup(signupInfo: TestUserSignupInfo, completion: @escaping (Result<AuthInfo, NetworkError>) -> Void)
    func signin(signinInfo: TestUserSigninInfo, completion: @escaping (Result<AuthInfo, NetworkError>) -> Void)
}