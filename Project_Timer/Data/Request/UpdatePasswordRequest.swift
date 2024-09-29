//
//  UpdatePasswordRequest.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/03/16.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation

struct UpdatePasswordRequest: Encodable {
    let username: String
    let email: String
    let newPassword: String
}
