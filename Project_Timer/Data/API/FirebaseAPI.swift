//
//  FirebaseAPI.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/04/17.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Moya

enum FirebaseAPI {
    case getAppVersion
    case getServerURL
    case getNotification
    case getTiTiFunctions
    case getUpdateHistorys
    case getYoutubeLink
    case getSurveys
}

extension FirebaseAPI: TargetType {
    var baseURL: URL {
        return URL(string: Infos.FirestoreURL.value)!
    }
    
    var path: String {
        switch self {
        case .getAppVersion:
            #if targetEnvironment(macCatalyst)
            return "/version/macos"
            #else
            return "/version/ios"
            #endif
        case .getServerURL:
            return "/server/url"
        case .getNotification:
            switch Language.current {
            case .ko: return "/notification/ko"
            case .en: return "/notification/en"
            case .zh: return "/notification/zh"
            }
        case .getTiTiFunctions:
            switch Language.current {
            case .ko: return "/titifuncs"
            case .en, .zh: return "/titifuncs_eng"
            }
        case .getUpdateHistorys:
            switch Language.current {
            case .ko: return "/updates"
            case .en, .zh: return "/updates_eng"
            }
        case .getYoutubeLink:
            return "/youtube"
        case .getSurveys:
            switch Language.current {
            case .ko: return "/surveys"
            case .en, .zh: return "/surveys_eng"
            }
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAppVersion, .getServerURL, .getNotification, .getTiTiFunctions, .getUpdateHistorys, .getYoutubeLink, .getSurveys:
            return .get
        }
    }
    
    var task: Moya.Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
}
