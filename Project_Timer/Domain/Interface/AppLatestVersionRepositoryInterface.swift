//
//  AppLatestVersionRepositoryInterface.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/03.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation

protocol AppLatestVersionRepositoryInterface {
    func get(completion: @escaping (Result<AppLatestVersionInfo, NetworkError>) -> Void)
}
