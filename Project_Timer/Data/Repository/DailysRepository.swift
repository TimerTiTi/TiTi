//
//  DailysRepository.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/06/09.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Moya
import Combine
import CombineMoya

final class DailysRepository {
    private let api: TTProvider<DailysAPI>
    
    init(api: TTProvider<DailysAPI>) {
        self.api = api
    }
    
    func uploadDailys(request: [Daily]) -> AnyPublisher<Bool, NetworkError> {
        let headers: [String: String] = [
            "gmt": "\(TimeZone.current.secondsFromGMT())"
        ]
        return self.api.request(.postDailys(body: request, headers: headers))
            .map { _ in true }
            .catchDecodeError()
    }
    
    func getDailys() -> AnyPublisher<[Daily], NetworkError> {
        return self.api.request(.getDailys)
            .map([DailyResponse].self)
            .map { $0.map { $0.toDomain() } }
            .catchDecodeError()
    }
}
