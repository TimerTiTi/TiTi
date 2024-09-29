//
//  RecordTimesRepository.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/06/09.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Moya
import Combine
import CombineMoya

final class RecordTimesRepository {
    private let api: TTProvider<DailysAPI>
    
    init(api: TTProvider<DailysAPI>) {
        self.api = api
    }
    
    func upload(request: RecordTimes) -> AnyPublisher<Bool, NetworkError> {
        return self.api.request(.postRecordTime(request))
            .map { _ in true }
            .catchDecodeError()
    }
    
    func get() -> AnyPublisher<RecordTimes, NetworkError> {
        return self.api.request(.getRecordTime)
            .map(RecordTimesResponse.self)
            .map { $0.toDomain() }
            .catchDecodeError()
    }
}
