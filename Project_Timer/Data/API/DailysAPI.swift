//
//  DailysAPI.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/04/17.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Moya

enum DailysAPI {
    case postDailys(body: [Daily], headers: [String: String])
    case getDailys
    case postRecordTime(RecordTimes)
    case getRecordTime
    case getSyncLog
}

extension DailysAPI: TargetType {
    var baseURL: URL {
        return URL(string: NetworkURL.shared.serverURL ?? "nil")!
    }
    
    var path: String {
        switch self {
        case .postDailys:
            return "/dailys/upload"
        case .getDailys:
            return "/dailys"
        case .postRecordTime, .getRecordTime:
            return "/recordTime"
        case .getSyncLog:
            return "/syncLog"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postDailys, .postRecordTime:
            return .post
        case .getDailys, .getRecordTime, .getSyncLog:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postDailys(let body, _):
            return .requestCustomJSONEncodable(body, encoder: .dateFormatted)
        case .postRecordTime(let recordTimes):
            return .requestCustomJSONEncodable(recordTimes, encoder: .dateFormatted)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .postDailys(_, let headers):
            return headers
        default:
            return nil
        }
    }
}
