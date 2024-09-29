//
//  SurveyResponse.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/07/03.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

/// Network 수신 DTO
struct SurveyResponse: Decodable {
    let surveyInfos: [SurveyInfo]?
    
    enum CodingKeys: String, CodingKey {
        case surveyInfos = "documents"
    }
}
