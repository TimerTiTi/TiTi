//
//  NotificationUseCaseInterface.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2023/12/27.
//  Copyright © 2023 FDEE. All rights reserved.
//

import Foundation

protocol NotificationUseCaseInterface {
    func isShowNotification() -> Bool
    func setPassDay()
}
