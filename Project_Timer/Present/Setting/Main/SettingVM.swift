//
//  SettingVM.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/06/01.
//  Copyright © 2022 FDEE. All rights reserved.
//

import Foundation
import Combine

final class SettingVM {
    private let getAppVersionUseCase: GetAppVersionUseCase
    @Published private(set) var cells: [[SettingCellInfo]] = []
    @Published private(set) var latestVersionFetched: Bool = false
    private(set) var sections: [String] = []
    private let isIpad: Bool
    // Combine binding
    private var cancellables = Set<AnyCancellable>()
    
    init(getAppVersionUseCase: GetAppVersionUseCase, isIpad: Bool) {
        self.getAppVersionUseCase = getAppVersionUseCase
        self.isIpad = isIpad
        self.configureSections()
        self.configureCells()
    }
    
    private func configureSections() {
        // MARK: Dev
        if Infos.isDevMode {
            self.sections.append(Localized.string(.Settings_Text_ProfileSection))
        }
        
        self.sections.append(Localized.string(.Settings_Text_ServiceSection))
        self.sections.append(Localized.string(.Settings_Text_SettingSection))
        self.sections.append(Localized.string(.Settings_Text_VersionSection))
        self.sections.append(Localized.string(.Settings_Text_BackupSection))
        self.sections.append(Localized.string(.Settings_Text_DeveloperSection))
    }
    
    private func configureCells() {
        let versionCell = SettingCellInfo(title: Localized.string(.Settings_Button_VersionInfoTitle), subTitle: Localized.string(.Settings_Button_VersionInfoDesc)+":", rightTitle: String.currentVersion, action: .otherApp, destination: .deeplink(url: NetworkURL.appstore))
        
        var cells: [[SettingCellInfo]] = []
        // MARK: Dev
        if Infos.isDevMode {
            // Profile
            cells.append([
                SettingCellInfo(title: Localized.string(.Settings_Button_SingInOption), subTitle: Localized.string(.Settings_Button_SingInOptionDesc), action: .modalFullscreen, destination: .signinSelect)
            ])
        }
        
        // Service
        cells.append([
            SettingCellInfo(title: Localized.string(.Settings_Button_Functions), action: .pushVC, destination: .storyboardName(identifier: SettingFunctionsListVC.identifier)),
            SettingCellInfo(title: Localized.string(.Settings_Button_TiTiLab), action: .pushVC, destination: .storyboardName(identifier: SettingTiTiLabVC.identifier))
        ])
        
        // Setting
        cells.append([
            SettingCellInfo(title: Localized.string(.Settings_Button_Notification), action: .pushVC, destination: .notification),
            SettingCellInfo(title: Localized.string(.Settings_Button_UI), action: .pushVC, destination: .ui),
            SettingCellInfo(title: Localized.string(.Settings_Button_Control), action: .pushVC, destination: .control),
            SettingCellInfo(title: Localized.string(.Settings_Button_LanguageOption), action: .pushVC, destination: .language),
            SettingCellInfo(title: Localized.string(.Settings_Button_Widget), action: .pushVC, destination: .widget)
        ])
        
        #if targetEnvironment(macCatalyst)
        cells.last?.remove(at: 2) // Control 제거
        #endif
        
        // Version & Update history
        cells.append([
            versionCell,
            SettingCellInfo(title: Localized.string(.Settings_Button_UpdateHistory), action: .pushVC, destination: .storyboardName(identifier: SettingUpdateHistoryVC.identifier))
        ])
        
        // Backup
        cells.append([
            SettingCellInfo(title: Localized.string(.Settings_Button_GetBackup), action: .activityVC, destination: .backup)
        ])
        
        // Developer
        cells.append([
            SettingCellInfo(title: "FDEE")
        ])
        
        self.cells = cells
        
        self.getAppVersionUseCase.execute()
          .sink { completion in
              if case .failure(let networkError) = completion {
                  print("ERROR", #function, networkError)
              }
          } receiveValue: { [weak self] appLatestVersionInfo in
              versionCell.updateSubTitle(to: Localized.string(.Settings_Button_VersionInfoDesc)+": \(appLatestVersionInfo.latestVersion)")
              self?.latestVersionFetched = true
          }
          .store(in: &self.cancellables)
    }
}
