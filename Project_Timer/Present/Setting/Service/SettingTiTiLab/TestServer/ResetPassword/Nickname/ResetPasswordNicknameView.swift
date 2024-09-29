//
//  ResetPasswordNicknameView.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/03/16.
//  Copyright © 2024 FDEE. All rights reserved.
//

import SwiftUI
import Combine
import Moya

struct ResetPasswordNicknameView: View {
    @ObservedObject private var keyboard = KeyboardResponder.shared
    @StateObject private var model: ResetPasswordNicknameModel
    @EnvironmentObject var environment: ResetPasswordEnvironment
    
    init(model: ResetPasswordNicknameModel) {
        _model = StateObject(wrappedValue: model)
    }
    
    var body: some View {
        NavigationStack(path: $environment.navigationPath) {
            GeometryReader { geometry in
                ZStack {
                    Colors.firstBackground.toColor
                        .ignoresSafeArea()
                    
                    VStack {
                        HStack(alignment: .center) {
                            Button {
                                self.environment.dismiss = true
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(Font.system(size: 20, weight: .medium))
                                    .foregroundStyle(UIColor.label.toColor)
                                    .padding(8)
                            }
                            Spacer()
                        }
                        .frame(height: 40)
                        
                        ContentView(model: model)
                            .padding(.bottom, keyboard.keyboardHeight+16)
                    }
                    
                }
                .onChange(of: geometry.size) { newValue in
                    model.updateContentWidth(size: newValue)
                }
            }
            .navigationDestination(for: ResetPasswordNicknameRoute.self) { destination in
                switch destination {
                case .resetPasswordEmail:
                    // TODO: DI 수정
                    let api = TTProvider<AuthAPI>(session: Session(interceptor: NetworkInterceptor.shared))
                    let repository = AuthRepository(api: api)
                    let checkEmailExitUseCase = CheckEmailExitUseCase(repository: repository)
                    let viewModel = ResetPasswordEmailModel(checkEmailExitUseCase: checkEmailExitUseCase, infos: model.resetPasswordInfosForEmail)
                    ResetPasswordEmailView(model: viewModel)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .configureForTextFieldRootView()
        }
        .accentColor(UIColor.label.toColor)
    }
    
    struct ContentView: View {
        @EnvironmentObject var environment: ResetPasswordEnvironment
        @ObservedObject var model: ResetPasswordNicknameModel
        @FocusState private var focus: TTSignupTextFieldView.type?
        
        var body: some View {
            ZStack {
                ScrollViewReader { ScrollViewProxy in
                    ScrollView {
                        HStack {
                            Spacer()
                            VStack {
                                TTSignupTitleView(title: Localized.string(.SignIn_Button_FindPassword), subTitle: Localized.string(.FindAccount_Text_InputNicknameDesc))
                                
                                TTSignupTextFieldView(type: .nickname, keyboardType: .default, text: $model.nickname, focus: $focus) {
                                    self.model.checkNickname()
                                }
                                .onChange(of: self.model.nickname) { newValue in
                                    self.model.validNickname = nil
                                }
                                TTSignupTextFieldUnderlineView(color: self.model.nicknameTintColor)
                                TTSignupTextFieldWarning(warning: model.errorMessage?.message ?? "", visible: self.model.nicknameWarningVisible)
                                    .id(TTSignupTextFieldView.type.nickname)
                            }
                            .onAppear { // @FocusState 변화 반영
                                if self.model.validNickname == nil && self.model.nickname.isEmpty {
                                    self.focus = .nickname
                                }
                            }
                            .onChange(of: focus, perform: { value in
                                self.model.updateFocus(to: value)
                                self.scroll(ScrollViewProxy, to: value)
                            })
                            .onReceive(model.$validNickname, perform: { valid in
                                if valid == true {
                                    self.environment.navigationPath.append(ResetPasswordNicknameRoute.resetPasswordEmail)
                                } else {
                                    self.focus = .nickname
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

struct ResetPasswordNicknameView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: DI 수정
        let api = TTProvider<AuthAPI>(session: Session(interceptor: NetworkInterceptor.shared))
        let repository = AuthRepository(api: api)
        let checkUsernameExitUseCase = CheckUsernameExitUseCsae(repository: repository)
        let viewModel = ResetPasswordNicknameModel(checkUsenameExitUseCase: checkUsernameExitUseCase)
        
        ResetPasswordNicknameView(
            model: viewModel)
        .environmentObject(ResetPasswordEnvironment())
    }
}
