//
//  FirebaseStringValue.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/07/03.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

struct FirebaseStringValue: Decodable {
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    private enum CodingKeys: String, CodingKey {
        case value = "stringValue"
    }
}
