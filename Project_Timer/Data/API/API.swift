//
//  API.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/04/17.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Moya

extension TargetType {
    static func parameters(from encodable: Encodable) -> [String: Any] {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(encodable),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return [:]
        }
        
        return dictionary
    }
}

extension JSONEncoder {
    static var dateFormatted: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
