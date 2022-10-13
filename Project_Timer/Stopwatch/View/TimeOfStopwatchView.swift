//
//  TimeOfStopwatchView.swift
//  Project_Timer
//
//  Created by 최수정 on 2022/06/27.
//  Copyright © 2022 FDEE. All rights reserved.
//

import SwiftUI

struct TimeOfStopwatchView: View {
    @ObservedObject var viewModel: BaseTimeLabelVM
    
    var color: Color {
        if viewModel.isRunning {
            return Color.stopWatchColor
        } else {
            return viewModel.isWhite ? .white : .black.opacity(0.5)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if viewModel.timeLabel.hourTens > 0 {
                BaseSingleTimeLabelView(viewModel: viewModel.hourTensViewModel)
            }
            BaseSingleTimeLabelView(viewModel: viewModel.hourUnitsViewModel)
            Text(":")
            BaseSingleTimeLabelView(viewModel: viewModel.minuteTensViewModel)
            BaseSingleTimeLabelView(viewModel: viewModel.minuteUnitsViewModel)
            Text(":")
            BaseSingleTimeLabelView(viewModel: viewModel.secondTensViewModel)
            BaseSingleTimeLabelView(viewModel: viewModel.secondUnitsViewModel)
        }
        .font(TiTiFont.HGGGothicssiP60g(size: viewModel.fontSize))
        .foregroundColor(self.color)
    }
}
