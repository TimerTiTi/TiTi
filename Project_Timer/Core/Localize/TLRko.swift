//
//  TLRko.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/10.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation

struct TLRko {
    static func value(key: TLRkey, op: String? = nil) -> String {
        var value: String = ""
        switch key {
        case .Update_Popup_HardUpdateTitle: value = "업데이트가 필요해요"
        case .Update_Popup_HardUpdateDesc: value = "최신버전으로 업데이트 해주세요"
        case .Update_Pupup_SoftUpdateTitle: value = "새로운 업데이트 알림"
        case .Update_Popup_SoftUpdateDesc: value = "{} 버전을 사용해보세요 :)"
        case .Update_Popup_Update: value = "업데이트"
        case .Update_Popup_NotNow: value = "나중에"
        case .ok: value = "확인"
            
        case .Settings_Button_SingInOption: value = "로그인하기"
        case .Settings_Button_SingInOptionDesc: value = "동기화 기능을 사용해보세요"
            
        case .SignIn_Text_TimerTiTi: value = "타이머티티"
        case .SignIn_Button_SocialSignIn: value = "{}로 로그인"
        case .SignIn_Button_WithoutSocialSingIn: value = "로그인없이 서비스 이용하기"
        case .SignIn_Hint_Email: value = "이메일"
        case .SignIn_Hint_Password: value = "비밀번호"
        case .SignIn_Button_TiTiSingIn: value = "로그인"
        case .SignIn_Text_OR: value = "또는"
        case .SignIn_Button_FindEmail: value = "이메일 찾기"
        case .SignIn_Button_FindPassword: value = "비밀번호 찾기"
        case .SignUp_Button_SignUp: value = "회원가입"
            
        case .SignUp_Text_InputEmailTitle: value = "이메일을 입력해 주세요"
        case .SignUp_Text_InputEmailDesc: value = "이메일 인증으로 본인을 확인해 주세요"
        case .SignUp_Hint_Email: value = "이메일"
        case .SignUp_Error_WrongEmailFormat: value = "잘못된 형식입니다. 올바른 형식으로 입력해 주세요"
        case .SignUp_Toast_SendCodeComplete: value = "인증코드가 발송되었습니다. 이메일을 확인해 주세요"
        case .SignUp_Hint_VerificationCode: value = "인증코드"
        case .SignUp_Button_Resend: value = "재전송"
        case .SignUp_Error_DuplicateEmail: value = "이미 사용 중인 이메일입니다. 다른 이메일을 입력해 주세요"
        case .SignUp_Error_WrongCode: value = "인증코드가 올바르지 않습니다. 다시 확인해 주세요"
        case .SignUp_Error_TooManySend: value = "인증코드 전송 시도가 너무 많습니다. 60분간 요청이 제한돼요"
        case .SignUp_Error_TooManyConfirm: value = "인증코드 확인 시도가 너무 많습니다. 10분간 요청이 제한돼요"
        }
        
        if let op = op, value.contains("{}") {
            value = value.replacingOccurrences(of: "{}", with: "\(op)")
        }
        
        return value
    }
}
