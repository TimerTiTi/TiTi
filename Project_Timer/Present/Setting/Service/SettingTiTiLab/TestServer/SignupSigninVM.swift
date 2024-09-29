//
//  SignupSigninVM.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/09/27.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation
import Combine

final class SignupSigninVM {
    private let signupUseCase: SignupUseCase
    private let signinUseCase: SigninUseCase
    let isSignin: Bool
    @Published var loadingText: String?
    @Published var alert: (title: String, text: String)?
    @Published var postable: Bool = false
    @Published var signinSuccess: Bool = false
    // Combine binding
    private var cancellables = Set<AnyCancellable>()
    
    init(signupUseCase: SignupUseCase, signinUseCase: SigninUseCase, isSignin: Bool) {
        self.signupUseCase = signupUseCase
        self.signinUseCase = signinUseCase
        self.isSignin = isSignin
        
        self.checkServerURL()
    }
    
    private func checkServerURL() {
        NetworkURL.shared.getServerURL()
            .sink { [weak self] url in
                if url == nil {
                    self?.alert = (title: Localized.string(.Server_Popup_ServerCantUseTitle), text: Localized.string(.Server_Popup_ServerCantUseDesc))
                }
            }
            .store(in: &self.cancellables)
        
    }
    
    func signup(request: TestUserSignupRequest) {
        self.loadingText = "Waiting for Signup..."
        self.signupUseCase.execute(request: request)
            .sink { [weak self] completion in
                self?.loadingText = nil
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                    switch networkError {
                        // signup 관련 error message 추가
                    case .CLIENTERROR(_):
                        self?.alert = (title: Localized.string(.SignUp_Error_SignupError), text: Localized.string(.SignUp_Error_CheckNicknameOrEmail))
                    default:
                        self?.alert = networkError.alertMessage
                    }
                }
            } receiveValue: { [weak self] authInfo in
                self?.saveUserInfo(authInfo: authInfo, password: request.password)
            }
            .store(in: &self.cancellables)
    }
    
    func signin(request: TestUserSigninRequest) {
        self.loadingText = "Waiting for Signin..."
        self.signinUseCase.execute(request: request)
            .sink { [weak self] completion in
                self?.loadingText = nil
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                    switch networkError {
                        // signin 관련 error message 추가
                    case .CLIENTERROR(_):
                        self?.alert = (title: Localized.string(.SignIn_Error_SigninFail), text: Localized.string(.SignIn_Error_CheckNicknameOrPassword))
                        // TestServer 에러핸들링 이슈로 404코드 추가
                    case .NOTFOUND(_):
                        self?.alert = (title: Localized.string(.SignIn_Error_SigninFail), text: Localized.string(.SignIn_Error_CheckNicknameOrPassword))
                    default:
                        self?.alert = networkError.alertMessage
                    }
                }
            } receiveValue: { [weak self] authInfo in
                self?.saveUserInfo(authInfo: authInfo, password: request.password)
            }
            .store(in: &self.cancellables)
    }
    
    func check(nickname: String?, email: String?, password: String?) {
        if self.isSignin {
            self.postable = [nickname, password].allSatisfy({ $0 != nil && $0 != "" })
        } else {
            self.postable = [nickname, email, password].allSatisfy({ $0 != nil && $0 != "" })
        }
    }
    
    private func saveUserInfo(authInfo: AuthInfo, password: String) {
        // MARK: Token 저장, Noti signined
        guard [KeyChain.shared.save(key: .username, value: authInfo.username),
               KeyChain.shared.save(key: .password, value: password),
               KeyChain.shared.save(key: .token, value: authInfo.token)].allSatisfy({ $0 }) == true else {
            self.alert = (title: "Keychain save fail", text: "")
            return
        }
        
        UserDefaultsManager.set(to: true, forKey: .signinInTestServerV1)
        NotificationCenter.default.post(name: KeyChain.signined, object: nil)
        
        self.signinSuccess = true
    }
}
