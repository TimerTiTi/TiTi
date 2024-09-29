//
//  ResetPasswordEmailView.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/03/16.
//  Copyright © 2024 FDEE. All rights reserved.
//

import SwiftUI
import Combine
import Moya

struct ResetPasswordEmailView: View {
    @ObservedObject private var keyboard = KeyboardResponder.shared
    @StateObject private var model: ResetPasswordEmailModel
    @EnvironmentObject var environment: ResetPasswordEnvironment
    
    init(model: ResetPasswordEmailModel) {
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
            .onChange(of: geometry.size) { newValue in
                model.updateContentWidth(size: newValue)
            }
            .navigationDestination(for: ResetPasswordEmailRoute.self) { destination in
                switch destination {
                case .resetPassword:
                    // TODO: DI 수정
                    let api = TTProvider<AuthAPI>(session: Session(interceptor: NetworkInterceptor.shared))
                    let repository = AuthRepository(api: api)
                    let updatePasswordUseCase = UpdatePasswordUseCase(repository: repository)
                    let viewModel = ResetPasswordModel(updatePasswordUseCase: updatePasswordUseCase, infos: model.resetPasswordInfosForPassword)
                    ResetPasswordView(model: viewModel)
                }
            }
        }
        .configureForTextFieldRootView()
    }
    
    struct ContentView: View {
        @EnvironmentObject var environment: ResetPasswordEnvironment
        @ObservedObject var model: ResetPasswordEmailModel
        @FocusState private var focus: TTSignupTextFieldView.type?
        
        var body: some View {
            ZStack {
                ScrollViewReader { ScrollViewProxy in
                    ScrollView {
                        HStack {
                            Spacer()
                            VStack {
                                TTSignupTitleView(title: Localized.string(.SignIn_Button_FindPassword), subTitle: Localized.string(.FindAccount_Text_InputEmailDesc))
                                
                                TTSignupTextFieldView(type: .email, keyboardType: .emailAddress, text: $model.email, focus: $focus) {
                                    self.model.checkEmail()
                                }
                                .onChange(of: self.model.email) { newValue in
                                    self.model.validEmail = nil
                                }
                                TTSignupTextFieldUnderlineView(color: self.model.emailTintColor)
                                TTSignupTextFieldWarning(warning: model.errorMessage?.message ?? "", visible: self.model.emailWarningVisible)
                                    .id(TTSignupTextFieldView.type.email)
                            }
                            .onAppear { // @FocusState 변화 반영
                                if self.model.validEmail == nil && self.model.email.isEmpty {
                                    self.focus = .email
                                }
                            }
                            .onChange(of: focus, perform: { value in
                                self.model.updateFocus(to: value)
                                self.scroll(ScrollViewProxy, to: value)
                            })
                            .onReceive(model.$validEmail, perform: { valid in
                                if valid == true {
                                    self.environment.navigationPath.append(ResetPasswordEmailRoute.resetPassword)
                                } else {
                                    self.focus = .email
                                    self.scroll(ScrollViewProxy, to: focus)
                                }
                            })
                            .frame(width: self.model.contentWidth)
                            Spacer()
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
    }
}

struct ResetPasswordEmailView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: DI 수정
        let api = TTProvider<AuthAPI>(session: Session(interceptor: NetworkInterceptor.shared))
        let repository = AuthRepository(api: api)
        let checkEmailExitUseCase = CheckEmailExitUseCase(repository: repository)
        let viewModel = ResetPasswordEmailModel(checkEmailExitUseCase: checkEmailExitUseCase, infos: .init(nickname: "minsang"))
        
        ResetPasswordEmailView(model: viewModel)
        .environmentObject(ResetPasswordEnvironment())
    }
}
