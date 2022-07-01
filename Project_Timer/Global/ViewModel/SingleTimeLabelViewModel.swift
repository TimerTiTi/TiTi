//
//  SingleTimeLabelViewModel.swift
//  Project_Timer
//
//  Created by 최수정 on 2022/06/24.
//  Copyright © 2022 FDEE. All rights reserved.
//

import SwiftUI

class SingleTimeLabelViewModel: ObservableObject {
    @Published var isUpdateComplete: Bool
    @Published var oldValue: Int
    @Published var newValue: Int
    
    init(old: Int, new: Int) {
        self.isUpdateComplete = true
        self.oldValue = old
        self.newValue = new
    }
    
    func update(old: Int, new: Int, showsAnimation: Bool) {
        guard new != newValue else { return }
        
        self.oldValue = old
        self.isUpdateComplete = false
        self.newValue = new
        
        if showsAnimation {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.isUpdateComplete = true
            }
        } else {
            self.isUpdateComplete = true
        }
    }
}
