//
//  ResetPasswordEmailModel.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/03/16.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: State
final class ResetPasswordEmailModel: ObservableObject {
    enum ErrorMessage {
        case notExist
        case serverError
        
        var message: String {
            switch self {
            case .notExist:
                return Localized.string(.FindAccount_Error_NotRegisteredEmail)
            case .serverError:
                return Localized.string(.Server_Error_CheckNetwork)
            }
        }
    }
    @Published var contentWidth: CGFloat = .zero
    @Published var focus: TTSignupTextFieldView.type?
    @Published var validEmail: Bool?
    @Published var errorMessage: ErrorMessage?
    
    @Published var email: String = ""
    // Combine binding
    private var cancellables = Set<AnyCancellable>()
    
    private let checkEmailExitUseCase: CheckEmailExitUseCase
    private let infos: ResetPasswordInfosForEmail
    
    init(checkEmailExitUseCase: CheckEmailExitUseCase, infos: ResetPasswordInfosForEmail) {
        self.checkEmailExitUseCase = checkEmailExitUseCase
        self.infos = infos
    }
    
    var emailWarningVisible: Bool {
        return self.validEmail == false
    }
    
    // nicknameTextField underline 컬러
    var emailTintColor: Color {
        if self.emailWarningVisible {
            return Colors.wrongTextField.toColor
        } else {
            return self.focus == .email ? Color.blue : UIColor.placeholderText.toColor
        }
    }
    
    // resetPasswordInfosForEmail 반환
    var resetPasswordInfosForPassword: ResetPasswordInfosForPassword {
        return ResetPasswordInfosForPassword(
            nickname: self.infos.nickname,
            email: self.email
        )
    }
}

extension ResetPasswordEmailModel {
    // 화면크기에 따른 width 크기조정
    func updateContentWidth(size: CGSize) {
        switch size.deviceDetailType {
        case .iPhoneMini, .iPhonePro, .iPhoneMax:
            contentWidth = abs(size.minLength - 48)
        default:
            contentWidth = 400
        }
    }
    
    // @FocusState 값변화 반영
    func updateFocus(to focus: TTSignupTextFieldView.type?) {
        self.focus = focus
    }
    
    // email done 액션
    func checkEmail() {
        self.checkEmailExitUseCase.execute(request: .init(username: self.infos.nickname, email: self.email))
            .sink { [weak self] completion in
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                    self?.validEmail = false
                    switch networkError {
                    case .NOTFOUND(_):
                        self?.errorMessage = .notExist
                    default:
                        self?.errorMessage = .serverError
                        print(networkError.alertMessage)
                    }
                }
            } receiveValue: { [weak self] valid in
                self?.validEmail = valid
            }
            .store(in: &self.cancellables)
    }
}
