//
//  ServerURLResponse.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/05/15.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation

/// TiTi 서버 URL 정보
struct ServerURLResponse: Decodable {
    let base: FirebaseStringValue
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case base
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        
        self.base = try fieldContainer.decode(FirebaseStringValue.self, forKey: .base)
    }
}
