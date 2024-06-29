//
//  RecordTimesRepository.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/06/09.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Combine
import Moya
import CombineMoya

final class RecordTimesRepository {
    private let api: TTProvider<DailysAPI>
    
    init(api: TTProvider<DailysAPI>) {
        self.api = api
    }
    
    func upload(info: RecordTimes) -> AnyPublisher<Bool, NetworkError> {
        return self.api.request(.postRecordTime(info))
            .map { _ in true }
            .catchDecodeError()
    }
    
    func get() -> AnyPublisher<RecordTimes, NetworkError> {
        return self.api.requestPublisher(.getRecordTime)
            .map(RecordTimesDTO.self)
            .map { $0.toDomain() }
            .catchDecodeError()
    }
}
