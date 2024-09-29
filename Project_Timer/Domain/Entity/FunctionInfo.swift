//
//  FunctionInfo.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/06/29.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation

struct FunctionInfo: Decodable {
    let title: FirebaseStringValue
    let url: FirebaseStringValue
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    private enum FieldKeys: String, CodingKey {
        case title, url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        
        self.title = try fieldContainer.decode(FirebaseStringValue.self, forKey: .title)
        self.url = try fieldContainer.decode(FirebaseStringValue.self, forKey: .url)
    }
}
