//
//  TestUserSignupRequest.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/12/21.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

struct TestUserSignupRequest: Encodable {
    let username: String
    let email: String
    let password: String
}
