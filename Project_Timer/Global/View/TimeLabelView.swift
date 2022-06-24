//
//  TimeLabelView.swift
//  Project_Timer
//
//  Created by 최수정 on 2022/06/24.
//  Copyright © 2022 FDEE. All rights reserved.
//

import SwiftUI

struct TimeLabelView: View {
    @ObservedObject var viewModel: TimeLabelViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            SingleTimeLabelView(viewModel: viewModel.hourTensViewModel)
            
            SingleTimeLabelView(viewModel: viewModel.hourUnitsViewModel)
            
            Text(":")
                .font(Font.custom("HGGGothicssiP60g", size: 70))
                .foregroundColor(.white)
            
            SingleTimeLabelView(viewModel: viewModel.minuteTensViewModel)
            
            SingleTimeLabelView(viewModel: viewModel.minuteUnitsViewModel)

            Text(":")
                .font(Font.custom("HGGGothicssiP60g", size: 70))
                .foregroundColor(.white)
            
            SingleTimeLabelView(viewModel: viewModel.secondTensViewModel)
            
            SingleTimeLabelView(viewModel: viewModel.secondUnitsViewModel)
        }
    }
    
    var frameWidth: CGFloat {
        return self.viewModel.newHourTens > 0 ? 250 : 220
    }
}
