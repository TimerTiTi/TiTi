//
//  SimpleResponse.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/03/16.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation

/// Node.js 에서 받는 간단한 형태
struct SimpleResponse: Decodable {
    let data: Bool
    let message: String
}

extension SimpleResponse {
    func toDomain() -> Bool {
        return self.data
    }
}
