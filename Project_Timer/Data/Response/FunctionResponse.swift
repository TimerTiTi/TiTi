//
//  FunctionResponse.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/06/05.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

/// Network 수신 DTO
struct FunctionResponse: Decodable {
    let functionInfos: [FunctionInfo]
    
    enum CodingKeys: String, CodingKey {
        case functionInfos = "documents"
    }
}
