//
//  ResetPasswordView.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/03/16.
//  Copyright © 2024 FDEE. All rights reserved.
//

import SwiftUI
import Combine
import Moya

struct ResetPasswordView: View {
    @ObservedObject private var keyboard = KeyboardResponder.shared
    @EnvironmentObject var environment: ResetPasswordEnvironment
    @StateObject private var model: ResetPasswordModel
    
    init(model: ResetPasswordModel) {
        _model = StateObject(wrappedValue: model)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Colors.firstBackground.toColor
                    .ignoresSafeArea()
                
                ContentView(model: model)
                    .padding(.bottom, keyboard.keyboardHeight+16)
            }
            .onChange(of: geometry.size, perform: { value in
                model.updateContentWidth(size: value)
            })
            .navigationDestination(for: ResetPasswordRoute.self) { destination in
                switch destination {
                case .resetPasswordComplete:
                    let info = ChangeCompleteInfo(
                        title: Localized.string(.FindAccount_Text_ChangeCompletedTitle),
                        subTitle: Localized.string(.FindAccount_Text_ChangePasswordCompleted),
                        buttonTitle: Localized.string(.FindAccount_Button_GoToLogin)
                    )
                    let viewModel = ResetPasswordCompleteModel(
                        info: info) {
                            self.environment.resetSuccess = true
                        }
                    ResetPasswordCompleteView(model: viewModel)
                }
            }
        }
        .configureForTextFieldRootView()
    }
    
    struct ContentView: View {
        @EnvironmentObject var environment: ResetPasswordEnvironment
        @ObservedObject var model: ResetPasswordModel
        @FocusState private var focus: TTSignupTextFieldView.type?
        
        var body: some View {
            ZStack {
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        HStack {
                            Spacer()
                            VStack(alignment: .leading, spacing: 0) {
                                TTSignupTitleView(title: Localized.string(.FindAccount_Text_InputNewPasswordTitle), subTitle: Localized.string(.SignUp_Text_InputPasswordDesc))
                                
                                TTSignupSecureFieldView(type: .password, keyboardType: .alphabet, text: $model.password, focus: $focus) {
                                    self.model.checkPassword()
                                }
                                TTSignupTextFieldUnderlineView(color: self.model.passwordTintColor)
                                TTSignupTextFieldWarning(warning: Localized.string(.SignUp_Error_PasswordFormat), visible: self.model.passwordWarningVisible)
                                    .id(TTSignupTextFieldView.type.password)
                                
                                if self.model.stage == .password2 {
                                    NextContentView(model: self.model, focus: $focus)
                                }
                            }
                            .onAppear {
                                if self.model.stage == .password {
                                    self.focus = .password
                                }
                            }
                            .onChange(of: self.focus) { newValue in // @FocusState 변화 -> stage 반영
                                self.model.updateFocus(to: newValue)
                                self.scroll(scrollViewProxy, to: newValue)
                            }
                            .onReceive(self.model.$stage) { status in // stage 변화 -> @FocusState 반영
                                switch status {
                                case .password:
                                    self.focus = .password
                                case .password2:
                                    self.focus = .password2
                                }
                                self.scroll(scrollViewProxy, to: focus)
                            }
                            .onReceive(model.$validPassword2) { valid in
                                if valid == true {
                                    self.environment.navigationPath.append(ResetPasswordRoute.resetPasswordComplete)
                                }
                            }
                            .frame(width: self.model.contentWidth)
                            Spacer()
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
    }
    
    struct NextContentView: View {
        @ObservedObject var model: ResetPasswordModel
        @FocusState.Binding var focus: TTSignupTextFieldView.type?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: 35)
                Text(Localized.string(.SignUp_Text_ConfirmPasswordDesc))
                    .font(Typographys.font(.semibold_4, size: 14))
                    .foregroundStyle(Color.primary)
                Spacer()
                    .frame(height: 16)
                
                TTSignupSecureFieldView(type: .password2, keyboardType: .alphabet, text: $model.password2, focus: $focus) {
                    self.model.checkPassword2()
                }
                TTSignupTextFieldUnderlineView(color: self.model.password2TintColor)
                TTSignupTextFieldWarning(warning: self.model.errorMessage?.message ?? "", visible: self.model.password2WarningVisible)
                    .id(TTSignupTextFieldView.type.password2)
            }
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: DI 수정
        let api = TTProvider<AuthAPI>(session: Session(interceptor: NetworkInterceptor.shared))
        let repository = AuthRepository(api: api)
        let updatePasswordUseCase = UpdatePasswordUseCase(repository: repository)
        let viewModel = ResetPasswordModel(updatePasswordUseCase: updatePasswordUseCase, infos: .init(nickname: "minsang", email: "freedeveloper97@gmail.com"))
        
        ResetPasswordView(model: viewModel)
            .environmentObject(ResetPasswordEnvironment())
    }
}
