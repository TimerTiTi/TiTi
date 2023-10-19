//
//  LoginSelectView.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/09/24.
//  Copyright © 2023 FDEE. All rights reserved.
//

import SwiftUI

struct LoginSelectView: View {
    @EnvironmentObject var environment: LoginSignupEnvironment
    @State private var superViewSize: CGSize = .zero
    
    init() {
        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack(path: $environment.navigationPath) {
            GeometryReader { geometry in
                ZStack {
                    TiTiColor.loginBackground.toColor
                        .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        Spacer()
                        
                        ContentView(superViewSize: $superViewSize)
                        
                        Spacer()
                    }
                }
                .onChange(of: geometry.size, perform: { value in
                    self.superViewSize = value
                })
            }
            .navigationDestination(for: LoginSelectRoute.self) { destination in
                switch destination {
                case .signupNickname:
                    SignupNicknameView()
                case .login:
                    LoginView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
        }
        .accentColor(UIColor.label.toColor)
    }
    
    struct ContentView: View {
        @Binding var superViewSize: CGSize
        
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                Image(uiImage: TiTiImage.loginLogo)
                
                Spacer()
                    .frame(height: 8)
                
                Text(verbatim: "TimerTiTi")
                    .foregroundStyle(.black)
                    .font(TiTiFont.HGGGothicssiP80g(size: 15))
                
                Spacer()
                    .frame(height: 58)
                
                Text("#\("TimerTiTi".localized())")
                    .foregroundStyle(.black)
                    .font(TiTiFont.HGGGothicssiP80g(size: 33))
                
                Spacer()
                    .frame(height: 58)
                
                ButtonsView()
            }
            .frame(width: self.width)
        }
        
        // 화면크기에 따른 width 크기조정
        var width: CGFloat {
            let size = superViewSize
            switch size.deviceDetailType {
            case .iPhoneMini:
                return 300
            case .iPhonePro, .iPhoneMax:
                return size.minLength - 96
            default:
                return 400
            }
        }
    }
    
    struct ButtonsView: View {
        @EnvironmentObject var environment: LoginSignupEnvironment
        
        var body: some View {
            VStack(alignment: .center, spacing: 24) {
                AppleLoginButton {
                    print("Apple")
                }
                GoogleLoginButton {
                    print("Google")
                }
                EmailLoginButton {
                    environment.navigationPath.append(LoginSelectRoute.login)
                }
                Button {
                    environment.dismiss = true
                } label: {
                    Text("Using without Sign in")
                        .font(TiTiFont.HGGGothicssiP60g(size: 13))
                        .underline()
                        .foregroundColor(.black.opacity(0.5))
                        .padding(.all, 8)
                }
            }
        }
    }
}

struct LoginSelectView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSelectView().environmentObject(LoginSignupEnvironment())
    }
}
