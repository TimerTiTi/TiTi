//
//  LastestVersionInfo.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/08/09.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation

/// latestVersionDTO
struct LastestVersionInfo: Decodable {
    let iOS: FirebaseStringValue
    let macOS: FirebaseStringValue
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    private enum FieldKeys: String, CodingKey {
        case iOS
        case macOS
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        
        self.iOS = try fieldContainer.decode(FirebaseStringValue.self, forKey: .iOS)
        self.macOS = try fieldContainer.decode(FirebaseStringValue.self, forKey: .macOS)
    }
}
