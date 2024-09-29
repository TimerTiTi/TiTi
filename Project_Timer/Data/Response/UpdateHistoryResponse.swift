//
//  UpdateHistoryResponse.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/06/04.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

/// Network 수신 DTO
struct UpdateHistoryResponse: Decodable {
    var updateInfos: [UpdateHistoryInfo]
    
    enum CodingKeys: String, CodingKey {
        case updateInfos = "documents"
    }
}
