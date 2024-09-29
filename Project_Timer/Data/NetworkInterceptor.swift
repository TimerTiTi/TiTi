//
//  NetworkInterceptor.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/12/25.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation
import Alamofire
import Combine

/// accessToken, refreshToken 주입
final class NetworkInterceptor: RequestInterceptor {
    static let retryLimit = 3
    static let shared = NetworkInterceptor()
    private init() {}
    
    // Combine binding
    private var cancellables = Set<AnyCancellable>()
    
    /// network request 전에 token 설정
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix(NetworkURL.shared.serverURL ?? "nil") == true else {
            completion(.success(urlRequest))
            return
        }
        
        guard let token = KeyChain.shared.get(key: .token) else {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))
    }
    
    /// token 만료인 경우 signin 하여 token 발급 후 재시도
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount < Self.retryLimit else {
            completion(.doNotRetry)
            return
        }
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        print("***token 만료, retry 로직 진행")
        // signin -> get new token
        self.signinForToken { token in
            guard let token = token else {
                completion(.doNotRetryWithError(error))
                return
            }
            
            if KeyChain.shared.update(key: .token, value: token) {
                print("***token 재발급 완료")
                completion(.retry)
            } else {
                print("***token 재발급 실패")
                completion(.doNotRetryWithError(error))
            }
        }
    }
}

extension NetworkInterceptor {
    /// signin 과정을 통해 token 재발급
    private func signinForToken(completion: @escaping (String?) -> Void) {
        guard let username = KeyChain.shared.get(key: .username),
              let password = KeyChain.shared.get(key: .password) else { return }
        
        // TODO: DI 수정
        let api = TTProvider<AuthAPI>()
        let repository = AuthRepository(api: api)
        let signinUseCase = SigninUseCase(repository: repository)
        
        let signinInfo = TestUserSigninRequest(username: username, password: password)
        signinUseCase.execute(request: signinInfo)
            .sink { comp in
                if case .failure(let networkError) = comp {
                    print("ERROR", #function, networkError)
                    print(networkError.alertMessage)
                    completion(nil)
                }
            } receiveValue: { authInfo in
                completion(authInfo.token)
            }
            .store(in: &self.cancellables)
    }
}
