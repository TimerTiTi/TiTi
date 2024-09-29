//
//  ResetPasswordNicknameModel.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/03/16.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: State
final class ResetPasswordNicknameModel: ObservableObject {
    enum ErrorMessage {
        case notExist
        case serverError
        
        var message: String {
            switch self {
            case .notExist:
                return Localized.string(.FindAccount_Error_NotRegisteredNickname)
            case .serverError:
                return Localized.string(.Server_Error_CheckNetwork)
            }
        }
    }
    @Published var contentWidth: CGFloat = .zero
    @Published var focus: TTSignupTextFieldView.type?
    @Published var validNickname: Bool?
    @Published var errorMessage: ErrorMessage?
    @Published var nickname: String = ""
    // Combine binding
    private var cancellables = Set<AnyCancellable>()
    
    private let checkUsenameExitUseCase: CheckUsernameExitUseCsae
    
    init(checkUsenameExitUseCase: CheckUsernameExitUseCsae) {
        self.checkUsenameExitUseCase = checkUsenameExitUseCase
    }
    
    var nicknameWarningVisible: Bool {
        return self.validNickname == false
    }
    
    // nicknameTextField underline 컬러
    var nicknameTintColor: Color {
        if self.nicknameWarningVisible {
            return Colors.wrongTextField.toColor
        } else {
            return self.focus == .nickname ? Color.blue : UIColor.placeholderText.toColor
        }
    }
    
    // resetPasswordInfosForEmail 반환
    var resetPasswordInfosForEmail: ResetPasswordInfosForEmail {
        return ResetPasswordInfosForEmail(
            nickname: self.nickname
        )
    }
}

extension ResetPasswordNicknameModel {
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
    
    // nickname done 액션
    func checkNickname() {
        self.checkUsenameExitUseCase.execute(request: .init(username: self.nickname))
            .sink { [weak self] completion in
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                    self?.validNickname = false
                    switch networkError {
                    case .NOTFOUND(_):
                        self?.errorMessage = .notExist
                    default:
                        self?.errorMessage = .serverError
                        print(networkError.alertMessage)
                    }
                }
            } receiveValue: { [weak self] valid in
                self?.validNickname = valid
            }
            .store(in: &self.cancellables)
    }
}
