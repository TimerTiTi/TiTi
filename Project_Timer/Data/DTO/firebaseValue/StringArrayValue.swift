//
//  StringArrayValue.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/17.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation

struct StringArrayValue: Decodable {
    let arrayValue: StringValues
}

struct StringValues: Decodable {
    let values: [StringValue]
}
