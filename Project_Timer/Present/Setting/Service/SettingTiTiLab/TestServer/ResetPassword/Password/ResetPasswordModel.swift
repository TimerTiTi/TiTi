//
//  ResetPasswordModel.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/03/16.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: State
final class ResetPasswordModel: ObservableObject {
    enum Stage {
        case password
        case password2
    }
    enum ErrorMessage {
        case different
        case notExist
        case serverError
        
        var message: String {
            switch self {
            case .different:
                return Localized.string(.SignUp_Error_PasswordMismatch)
            case .notExist:
                return Localized.string(.FindAccount_Error_NotRegisteredNicknameEmail)
            case .serverError:
                return Localized.string(.Server_Error_CheckNetwork)
            }
        }
    }
    
    @Published var contentWidth: CGFloat = .zero
    @Published var focus: TTSignupTextFieldView.type?
    @Published var validPassword: Bool?
    @Published var validPassword2: Bool?
    @Published var errorMessage: ErrorMessage?
    @Published var stage: Stage = .password
    
    @Published var password: String = ""
    @Published var password2: String = ""
    // Combine binding
    private var cancellables = Set<AnyCancellable>()
    
    private let updatePasswordUseCase: UpdatePasswordUseCase
    private let infos: ResetPasswordInfosForPassword
    
    init(updatePasswordUseCase: UpdatePasswordUseCase, infos: ResetPasswordInfosForPassword) {
        self.updatePasswordUseCase = updatePasswordUseCase
        self.infos = infos
    }
    
    var passwordWarningVisible: Bool {
        return self.validPassword == false && self.password.isEmpty
    }
    
    var password2WarningVisible: Bool {
        return self.validPassword2 == false && self.password2.isEmpty
    }
    
    // passwordTextField underline 컬러
    var passwordTintColor: Color {
        if self.passwordWarningVisible {
            return Colors.wrongTextField.toColor
        } else {
            return self.focus == .password ? Color.blue : UIColor.placeholderText.toColor
        }
    }
    
    // passwordTextField2 underline 컬러
    var password2TintColor: Color {
        if self.password2WarningVisible {
            return Colors.wrongTextField.toColor
        } else {
            return self.focus == .password2 ? Color.blue : UIColor.placeholderText.toColor
        }
    }
}

// MARK: Action
extension ResetPasswordModel {
    // 화면크기에 따른 width 크기조정
    func updateContentWidth(size: CGSize) {
        switch size.deviceDetailType {
        case .iPhoneMini, .iPhonePro, .iPhoneMax:
            self.contentWidth = abs(size.minLength - 48)
        default:
            self.contentWidth = 400
        }
    }
    
    // @FocusState 값변화 -> stage 반영
    func updateFocus(to focus: TTSignupTextFieldView.type?) {
        self.focus = focus
        switch focus {
        case .password:
            self.resetPassword()
        case .password2:
            self.resetPassword2()
        default:
            return
        }
    }
    
    // password done 액션
    func checkPassword() {
        self.validPassword = PredicateChecker.isValidPassword(self.password)
        // stage 변화 -> @StateFocus 반영
        if self.validPassword == true {
            self.resetPassword2()
        } else {
            self.resetPassword()
        }
    }
    
    // password2 done 액션
    func checkPassword2() {
        let passwordValid = PredicateChecker.isValidPassword(self.password2)
        let samePassword = self.password == self.password2
        let validPassword2 = (passwordValid && samePassword)
        
        // stage 변화 -> @StateFocus 반영
        
        // 비밀번호가 일치하지 않는 경우 -> 해당 오류문구 표시
        if validPassword2 == false {
            self.validPassword2 = false
            self.errorMessage = .different
            self.resetPassword2()
        } 
        // 비밀번호가 일치하는 경우 서버 통신
        else {
            let request = UpdatePasswordRequest(
                username: self.infos.nickname,
                email: self.infos.email,
                newPassword: self.password2
            )
            
            self.updatePasswordUseCase.execute(request: request)
                .sink { [weak self] completion in
                    if case .failure(let networkError) = completion {
                        print("ERROR", #function, networkError)
                        self?.validPassword2 = false
                        switch networkError {
                        case .NOTFOUND(_):
                            self?.errorMessage = .notExist
                        default:
                            self?.errorMessage = .serverError
                            print(networkError.alertMessage)
                        }
                    }
                } receiveValue: { [weak self] success in
                    self?.validPassword2 = success
                }
                .store(in: &self.cancellables)
        }
    }
    
    private func resetPassword() {
        self.validPassword2 = nil
        self.password = ""
        self.stage = .password
    }
    
    private func resetPassword2() {
        self.password2 = ""
        self.stage = .password2
    }
}
