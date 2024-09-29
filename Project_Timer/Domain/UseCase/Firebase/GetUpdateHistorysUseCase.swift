//
//  GetUpdateHistorysUseCase.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/06/29.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Combine

final class GetUpdateHistorysUseCase {
    private let repository: FirebaseRepository // TODO: 프로토콜로 수정
    
    init(repository: FirebaseRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[UpdateHistoryInfo], NetworkError> {
        return self.repository.getUpdateHistorys()
    }
}
