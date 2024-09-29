//
//  SettingFunctionsListVM.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/06/05.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation
import Combine

final class SettingFunctionsListVM {
    private let getTiTiFunctionsUseCase: GetTiTiFunctionsUseCase
    @Published private(set) var infos: [FunctionInfo] = []
    @Published private(set) var warning: (title: String, text: String)?
    private(set) var youtubeLink: String?
    // Combine binding
    private var cancellables = Set<AnyCancellable>()
    
    init(getTiTiFunctionsUseCase: GetTiTiFunctionsUseCase) {
        self.getTiTiFunctionsUseCase = getTiTiFunctionsUseCase
        self.configureInfos()
    }
    
    private func configureInfos() {
        self.getTiTiFunctionsUseCase.execute()
            .sink { [weak self] completion in
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                    self?.warning = networkError.alertMessage
                }
            } receiveValue: { [weak self] functionInfos in
                self?.infos = functionInfos
            }
            .store(in: &self.cancellables)
    }
}
