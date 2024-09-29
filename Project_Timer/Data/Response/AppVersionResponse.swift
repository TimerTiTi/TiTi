//
//  AppVersionResponse.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/05/15.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation

/// TiTi 최신버전 정보
struct AppVersionResponse: Decodable {
    let latestVersion: FirebaseStringValue
    let forced: FirebaseBooleanValue
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case latestVersion
        case forced
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContainer = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        
        self.latestVersion = try fieldContainer.decode(FirebaseStringValue.self, forKey: .latestVersion)
        self.forced = try fieldContainer.decode(FirebaseBooleanValue.self, forKey: .forced)
    }
}

extension AppVersionResponse {
    func toDomain() -> AppLatestVersionInfo {
        return .init(
            latestVersion: self.latestVersion.value,
            forced: self.forced.value
        )
    }
}
