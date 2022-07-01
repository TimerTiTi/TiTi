//
//  Color+Extension.swift
//  Project_Timer
//
//  Created by 최수정 on 2022/07/01.
//  Copyright © 2022 FDEE. All rights reserved.
//

import SwiftUI

extension Color {
    public static var stopWatchColor: Color {
        if let userColor = UserDefaults.standard.colorForKey(key: "color") {
            return Color(userColor)
        } else {
            return Color(UIColor(named: "Background2") ?? .clear)
        }
    }
}