//
//  SyncLogDTO.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/16.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation

struct SyncLogResponse: Decodable {
    let updatedAt: Date
    let dailysCount: Int
}

extension SyncLogResponse {
    func toDomain() -> SyncLog {
        return .init(
            updatedAt: self.updatedAt,
            dailysCount: self.dailysCount)
    }
}
