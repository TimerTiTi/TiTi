//
//  DailyView.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/09/13.
//  Copyright © 2022 FDEE. All rights reserved.
//

import SwiftUI

struct DailyView: View {
    let frameHeight: CGFloat = 90
    @ObservedObject var viewModel: DailyVM
    
    init(viewModel: DailyVM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            HStack(alignment: .bottom, spacing: 9) {
                self.DateTextView
                self.DaysOfWeekView
            }
            self.TimelineAlphaGraphView
            self.TimelineStickGraphView
        }
        .padding(.horizontal, 11)
    }
}

// MARK: CustomViews
extension DailyView {
    var DateTextView: some View {
        Text(self.dateText)
            .font(TiTiFont.HGGGothicssiP80g(size: 24))
    }
    
    var DaysOfWeekView: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(0..<7) { idx in
                DayOfWeekText(today: viewModel.day.zeroDate.localDate, dayIndex: idx, colorIndex: viewModel.color2Index)
            }
        }
        .padding(.bottom, 3)
    }
    
    var TimelineAlphaGraphView: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(viewModel.times) { time in
                Circle()
                    .fill(self.timeColor(time: time.sumTime))
            }
        }
    }
    
    var TimelineStickGraphView: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(viewModel.times) { time in
                VStack(alignment: .center, spacing: 2) {
                    RoundedShape()
                        .fill(LinearGradient(gradient: .init(colors: [TiTiColor.graphColor(num: viewModel.color1Index).toColor, TiTiColor.graphColor(num: viewModel.color2Index).toColor]), startPoint: .top, endPoint: .bottom))
                        .frame(height: self.getHeight(time: time.sumTime))
                    Text("\(time.id)")
                        .font(.system(size: 8))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.top, 4)
    }
}

// MARK: Propertys
extension DailyView {
    private var dateText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd"
        return dateFormatter.string(from: viewModel.day.zeroDate.localDate)
    }
    
    private func timeColor(time: Int) -> Color {
        let color = TiTiColor.graphColor(num: viewModel.color2Index)
        if time == 0 {
            return UIColor(named: "Empty")?.toColor ?? .clear
        } else if time >= 3000 {
            return color.toColor
        } else {
            if time < 600 {
                return color.withAlphaComponent(0.2).toColor
            } else if time < 1200 {
                return color.withAlphaComponent(0.35).toColor
            } else if time < 1800 {
                return color.withAlphaComponent(0.5).toColor
            } else if time < 2400 {
                return color.withAlphaComponent(0.65).toColor
            } else {
                return color.withAlphaComponent(0.8).toColor
            }
        }
    }
    
    private func getHeight(time: Int) -> CGFloat {
        return CGFloat(time)/CGFloat(3600)*self.frameHeight
    }
}
