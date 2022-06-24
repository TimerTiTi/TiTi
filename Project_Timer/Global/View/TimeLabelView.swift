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
            SingleTimeLabelView(oldValue: viewModel.oldHourTens,
                                newValue: viewModel.newHourTens,
                                update: viewModel.updateHourTens)
                
            SingleTimeLabelView(oldValue: viewModel.oldHourUnits,
                                newValue: viewModel.newHourUnits,
                                update: viewModel.updateHourUnits)

            Text(":")
                .font(Font.custom("HGGGothicssiP60g", size: 70))
                .foregroundColor(.white)

            SingleTimeLabelView(oldValue: viewModel.oldMinuteTens,
                                newValue: viewModel.newMinuteTens,
                                update: viewModel.updateMinuteTens)
            
            SingleTimeLabelView(oldValue: viewModel.oldMinuteUnits,
                                newValue: viewModel.newMinuteUnits,
                                update: viewModel.updateMinuteUnits)

            Text(":")
                .font(Font.custom("HGGGothicssiP60g", size: 70))
                .foregroundColor(.white)

            SingleTimeLabelView(oldValue: viewModel.oldSecondTens,
                                newValue: viewModel.oldSecondTens,
                                update: viewModel.updateSecondTens)
            
            SingleTimeLabelView(oldValue: viewModel.oldSecondUnits,
                                newValue: viewModel.newSecondUnits,
                                update: viewModel.updateSecondUnits)
        }
        .frame(width: 300, height: 100, alignment: .center)
        
    }
}
