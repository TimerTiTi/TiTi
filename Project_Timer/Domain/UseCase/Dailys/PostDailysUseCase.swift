//
//  PostDailysUseCase.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/07/07.
//  Copyright © 2024 FDEE. All rights reserved.
//

import Foundation
import Combine

final class PostDailysUseCase {
    private let repository: DailysRepository // TODO: 프로토콜로 수정
    
    init(repository: DailysRepository) {
        self.repository = repository
    }
    
    func execute(request: [Daily]) -> AnyPublisher<Bool, NetworkError> {
        return self.repository.uploadDailys(request: request)
    }
}
