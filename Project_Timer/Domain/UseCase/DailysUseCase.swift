//
//  DailysUseCase.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/16.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation

final class DailysUseCase: DailysUseCaseInterface {
    let repository: DailysRepositoryInterface
    
    init(repository: DailysRepositoryInterface) {
        self.repository = repository
    }
    
    func uploadDailys(dailys: [Daily], completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        let newDailys = dailys.filter { $0.totalTime > 0}
        self.repository.upload(dailys: newDailys) { result in
            completion(result)
        }
    }
    
    func getDailys(completion: @escaping (Result<[Daily], NetworkError>) -> Void) {
        self.repository.get() { result in
            completion(result)
        }
    }
}
