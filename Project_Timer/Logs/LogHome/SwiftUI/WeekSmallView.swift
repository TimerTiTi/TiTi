//
//  WeekSmallView.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/09/06.
//  Copyright © 2022 FDEE. All rights reserved.
//

import SwiftUI

struct WeekSmallView: View {
    private let fontSize: CGFloat = 30
    private let lineWidth: CGFloat = 20
    private let circleSize: CGFloat = 105
    @ObservedObject var viewModel: WeekSmallVM
    
    init(viewModel: WeekSmallVM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(TiTiColor.graphColor(num: viewModel.colorIndex).toColor.opacity(0.5),
                            lineWidth: lineWidth)
                    .frame(width: circleSize, height: circleSize, alignment: .center)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(TiTiColor.graphColor(num: viewModel.colorIndex).toColor.opacity(1.0),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: circleSize, height: circleSize, alignment: .center)
                    .rotationEffect(.degrees(-90))
                
                Text("\(weekHours)")
                    .font(Fonts.HGGGothicssiP60g(size: fontSize))
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color("Background_second").edgesIgnoringSafeArea(.all))
    }
    
    var progress: CGFloat {
        return viewModel.maxTime != 0 ? CGFloat(viewModel.totalTime)/CGFloat(viewModel.maxTime) : 0
    }
    
    var weekHours: Int {
        return viewModel.totalTime/3600
    }
}
