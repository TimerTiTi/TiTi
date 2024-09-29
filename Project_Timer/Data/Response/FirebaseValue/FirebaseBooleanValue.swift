//
//  FirebaseBooleanValue.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/03.
//  Copyright © 2023 FDEE. All rights reserved.
//

struct FirebaseBooleanValue: Decodable {
    let value: Bool
    
    init(value: Bool) {
        self.value = value
    }
    
    private enum CodingKeys: String, CodingKey {
        case value = "booleanValue"
    }
}
