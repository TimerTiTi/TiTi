//
//  SignupNicknameView.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/11/21.
//  Copyright © 2023 FDEE. All rights reserved.
//

import SwiftUI
import Moya

struct SignupNicknameView: View {
    @EnvironmentObject var environment: SigninSignupEnvironment
    @ObservedObject private var keyboard = KeyboardResponder.shared
    @StateObject private var model: SignupNicknameModel
    
    init(model: SignupNicknameModel) {
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
            .navigationDestination(for: SignupNicknameRoute.self) { destination in
                switch destination {
                case .signupTermOfUse:
                    let infos = model.signupInfosForTermOfUse
                    Text("SignupTermOfUse")
                case .signupComplete:
                    ChangeCompleteView(
                        model: ChangeCompleteModel(
                            info: model.signupInfosForComplete,
                            buttonAction: {
                                self.environment.signupSuccess = true
                            }
                        )
                    )
                }
            }
        }
        .configureForTextFieldRootView()
    }
    
    struct ContentView: View {
        @EnvironmentObject var environment: SigninSignupEnvironment
        @ObservedObject var model: SignupNicknameModel
        @FocusState private var focus: TTSignupTextFieldView.type?
        
        var body: some View {
            ZStack {
                ScrollViewReader { ScrollViewProxy in
                    ScrollView {
                        HStack {
                            Spacer()
                            VStack {
                                TTSignupTitleView(title: Localized.string(.SignUp_Text_InputNicknameTitle), subTitle: Localized.string(.SignUp_Text_InputNicknameDesc))
                                
                                TTSignupTextFieldView(type: .nickname, keyboardType: .alphabet, text: $model.nickname, focus: $focus) {
                                    model.checkNickname()
                                }
                                .onChange(of: model.nickname) { newValue in
                                    model.validNickname = nil
                                }
                                TTSignupTextFieldUnderlineView(color: model.nicknameTintColor)
                                TTSignupTextFieldWarning(warning: Localized.string(.SignUp_Error_WrongNicknameFormat), visible: model.validNickname == false)
                                    .id(TTSignupTextFieldView.type.nickname)
                            }
                            .onAppear { // @FocusState 변화 반영
                                if model.validNickname == nil && model.nickname.isEmpty {
                                    focus = .nickname
                                }
                            }
                            .onChange(of: focus, perform: { value in
                                model.updateFocus(to: value)
                                scroll(ScrollViewProxy, to: value)
                            })
                            .onReceive(model.$validNickname, perform: { valid in
                                if valid == true {
//                                    environment.navigationPath.append(SignupNicknameRoute.signupTermOfUse)
                                    environment.navigationPath.append(SignupNicknameRoute.signupComplete)
                                } else {
                                    focus = .nickname
                                    scroll(ScrollViewProxy, to: focus)
                                }
                            })
                            .frame(width: model.contentWidth)
                            Spacer()
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
    }
}

struct SignupNicknameView_Previews: PreviewProvider {
    // TODO: AES/GCM/NoPadding 암호화 필요
    static let infos = SignupInfosForNickname(
        type: .normal,
        venderInfo: nil,
        emailInfo: SignupEmailInfo(
            email: "freedeveloper97@gmail.com",
            authToken: "abcd1234"),
        passwordInfo: SignupPasswordInfo(
            encryptedPassword: "Abcd1234!")
    )
    
    static var previews: some View {
        // TODO: DI 수정
        let userApi = TTProvider<UserAPI>(session: Session(interceptor: NetworkInterceptor.shared))
        let userRepository = UserRepository(api: userApi)
        let postSignupUseCase = PostSignupUseCase(repository: userRepository)
        SignupNicknameView(
            model: SignupNicknameModel(infos: infos, postSignupUseCase: postSignupUseCase))
        .environmentObject(SigninSignupEnvironment())
    }
}
