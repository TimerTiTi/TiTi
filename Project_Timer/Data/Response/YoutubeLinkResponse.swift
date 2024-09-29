//
//  youtubeLinkInfo.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/07/03.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

/// youtubeInfo DTO
struct YoutubeLinkResponse: Decodable {
    let url: FirebaseStringValue
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    private enum FieldKeys: String, CodingKey {
        case url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        
        self.url = try fieldContainer.decode(FirebaseStringValue.self, forKey: .url)
    }
}
