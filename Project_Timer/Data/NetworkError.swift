//
//  NetworkError.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/10/02.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation
import Moya

/// 네트워크 에러
enum NetworkError: Error {
    case FAIL
    case TIMEOUT
    case DECODEERROR
    case CLIENTERROR(String?) // 400
    case AUTHENTICATION(String?) // 401
    case NOTFOUND(String?) // 404
    case CONFLICT(String?) // 409
    case SERVERERROR(String?) // 500
    case ERRORRESPONSE(TTErrorResponse) // TiTi ErrorResponse
    
    static func serverError(statusCode: Int, data: Data? = nil) -> NetworkError {
        // MARK: Decoding 로직 필요
        let errorMessage: String? = ""
        switch statusCode {
        case 400:
            return .CLIENTERROR(errorMessage)
        case 401:
            return .AUTHENTICATION(errorMessage)
        case 404:
            return .NOTFOUND(errorMessage)
        case 409:
            return .CONFLICT(errorMessage)
        case 500:
            return .SERVERERROR(errorMessage)
        default:
            return .FAIL
        }
    }
    
    /// ErrorResponse 반환
    static func errorResponse(_ response: Response) -> NetworkError {
        guard let errorResponse = try? JSONDecoder().decode(TTErrorResponse.self, from: response.data) else {
            return .serverError(statusCode: response.statusCode)
        }
        return .ERRORRESPONSE(errorResponse)
    }
    
    /// 범용적으로 표시될 수 있는 alert title 값, CLIENTERROR의 경우 VM에서 처리
    var title: String {
        switch self {
        case .FAIL:
            return Localized.string(.Server_Error_NetworkError)
        case .TIMEOUT:
            return Localized.string(.Server_Error_NetworkTimeout)
        case .DECODEERROR:
            return Localized.string(.Server_Error_NetworkFetchError)
        case .AUTHENTICATION(_):
            return Localized.string(.SignIn_Error_AuthenticationError)
        case .NOTFOUND(_):
            return Localized.string(.Server_Error_NetworkFetchError)
        case .CONFLICT(_):
            return Localized.string(.SignUp_Error_SignupError)
        case .SERVERERROR(_):
            return Localized.string(.Server_Error_ServerError)
        default:
            return Localized.string(.Server_Error_NetworkError)
        }
    }
    
    /// 범용적으로 표시될 수 있는 alert message 값, CLIENTERROR의 경우 VM에서 처리
    var message: String {
        switch self {
        case .FAIL:
            return Localized.string(.Server_Error_CheckNetwork)
        case .TIMEOUT:
            return Localized.string(.Server_Error_CheckNetwork)
        case .DECODEERROR:
            return Localized.string(.Server_Error_DecodeError)
        case .AUTHENTICATION(_):
            return Localized.string(.SignIn_Error_SigninAgain)
        case .NOTFOUND(_):
            return Localized.string(.Server_Error_DecodeError)
        case .CONFLICT(_):
            return Localized.string(.SignUp_Error_EnterDifferentValue)
        case .SERVERERROR(_):
            return Localized.string(.Server_Error_ServerErrorTryAgain)
        default:
            return Localized.string(.Server_Error_CheckNetwork)
        }
    }
    
    /// 범용적으로 표시되는 alert문구의 조합을 반환
    var alertMessage: (title: String, text: String) {
        return (title: self.title, text: self.message)
    }
}
