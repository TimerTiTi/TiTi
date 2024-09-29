//
//  SettingUpdateHistoryVM.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/06/04.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation
import Combine

final class SettingUpdateHistoryVM {
    let getUpdateHistorysUseCase: GetUpdateHistorysUseCase
    @Published private(set) var infos: [UpdateHistoryInfo] = []
    @Published private(set) var warning: (title: String, text: String)?
    // Combine binding
    private var cancellables = Set<AnyCancellable>()
    
    init(getUpdateHistorysUseCase: GetUpdateHistorysUseCase) {
        self.getUpdateHistorysUseCase = getUpdateHistorysUseCase
        self.configureInfos()
    }
    
    private func configureInfos() {
        self.getUpdateHistorysUseCase.execute()
            .sink { [weak self] completion in
                if case .failure(let networkError) = completion {
                    print("ERROR", #function, networkError)
                    self?.warning = networkError.alertMessage
                }
            } receiveValue: { [weak self] updateHistoryInfos in
                self?.infos = updateHistoryInfos.sorted(by: {
                    $0.version.value.compare($1.version.value, options: .numeric) == .orderedDescending
                })
            }
            .store(in: &self.cancellables)
    }
}
