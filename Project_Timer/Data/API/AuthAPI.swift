//
//  AuthAPI.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/04/17.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Moya

enum AuthAPI {
    case postSignup(TestUserSignupRequest)
    case postSignin(TestUserSigninRequest)
    case getCheckUsername(CheckUsernameRequest)
    case getCheckEmail(CheckEmailExitRequest)
    case postUpdatePassword(UpdatePasswordRequest)
}

extension AuthAPI: TargetType {
    var baseURL: URL {
        return URL(string: NetworkURL.shared.serverURL ?? "nil")!
    }
    
    var path: String {
        switch self {
        case .postSignup:
            return "/auth/signup"
        case .postSignin:
            return "/auth/login"
        case .getCheckUsername, .getCheckEmail:
            return "/auth/users"
        case .postUpdatePassword:
            return "/auth/users/password"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postSignup, .postSignin, .postUpdatePassword:
            return .post
        case .getCheckUsername, .getCheckEmail:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postSignup(let request):
            return .requestJSONEncodable(request)
        case .postSignin(let request):
            return .requestJSONEncodable(request)
        case .getCheckUsername(let request):
            return .requestParameters(parameters: Self.parameters(from: request), encoding: URLEncoding.queryString)
        case .getCheckEmail(let request):
            return .requestParameters(parameters: Self.parameters(from: request), encoding: URLEncoding.queryString)
        case .postUpdatePassword(let request):
            return .requestJSONEncodable(request)
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
}

