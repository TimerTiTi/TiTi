//
//  DailysVC.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/07/16.
//  Copyright © 2022 FDEE. All rights reserved.
//

import UIKit
import SwiftUI
import FSCalendar

final class DailysVC: UIViewController {
    static let identifier = "DailysVC"
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet weak var graphsScrollView: UIScrollView!
    @IBOutlet weak var graphsContentView: UIView!
    @IBOutlet weak var graphsPageControl: UIPageControl!
    private var standardDailyGraphView = StandardDailyGraphView()
    private var timelineDailyGraphView = TimelineDailyGraphView()
    private var tasksProgressDailyGraphView = TasksProgressDailyGraphView()
    private var checkGraphButtons: [CheckGraphButton] = []
    private var currentDaily: Daily? {
        didSet {
            self.updateGraphs()
            self.timelineVM.update(daily: currentDaily)
        }
    }
    private let timelineVM = TimelineVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCalender()
        self.updateCalendarColor()
        self.configureScrollView()
        self.configureGraphs()
        self.configureCheckGraphs()
        self.configureTimelineHostingVC()
        
        self.currentDaily = RecordController.shared.daily
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.standardDailyGraphView.updateDarkLightMode()
        self.timelineDailyGraphView.updateDarkLightMode()
        self.tasksProgressDailyGraphView.updateDarkLightMode()
    }
    
    @IBAction func changeColor(_ sender: UIButton) {
        UserDefaultsManager.set(to: sender.tag, forKey: .startColor)
        self.updateGraphs()
        self.updateCalendarColor()
        self.timelineVM.updateColor()
        // reverse color 로직 고민
    }
}

extension DailysVC {
    private func configureCalender() {
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.appearance.headerDateFormat = "YYYY.MM"
        self.calendar.appearance.headerTitleFont = TiTiFont.HGGGothicssiP80g(size: 25)
        self.calendar.appearance.weekdayFont = TiTiFont.HGGGothicssiP80g(size: 13)
        self.calendar.appearance.titleFont = TiTiFont.HGGGothicssiP60g(size: 20)
        self.calendar.clipsToBounds = true
        self.calendar.layer.cornerCurve = .continuous
        self.calendar.layer.borderWidth = 2
        self.calendar.layer.cornerRadius = 25
        
        self.calendar.appearance.todayColor = UIColor.clear
        self.calendar.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.calendar.backgroundColor = UIColor(named: "Background_second")
    }
    
    private func updateCalendarColor() {
        let color = UIColor(named: String.userTintColor)
        self.calendar.appearance.titleTodayColor = color
        self.calendar.appearance.headerTitleColor = color
        self.calendar.appearance.weekdayTextColor = color
        self.calendar.appearance.selectionColor = color?.withAlphaComponent(0.5)
        self.calendar.appearance.eventSelectionColor = color?.withAlphaComponent(0.5)
    }
    
    private func configureScrollView() {
        self.graphsScrollView.delegate = self
    }
    
    private func configureGraphs() {
        self.graphsContentView.addSubview(self.standardDailyGraphView)
        NSLayoutConstraint.activate([
            self.standardDailyGraphView.topAnchor.constraint(equalTo: self.graphsContentView.topAnchor),
            self.standardDailyGraphView.leadingAnchor.constraint(equalTo: self.graphsContentView.leadingAnchor),
            self.standardDailyGraphView.bottomAnchor.constraint(equalTo: self.graphsContentView.bottomAnchor)
        ])
        
        self.graphsContentView.addSubview(self.timelineDailyGraphView)
        NSLayoutConstraint.activate([
            self.timelineDailyGraphView.topAnchor.constraint(equalTo: self.graphsContentView.topAnchor),
            self.timelineDailyGraphView.leadingAnchor.constraint(equalTo: self.standardDailyGraphView.trailingAnchor),
            self.timelineDailyGraphView.bottomAnchor.constraint(equalTo: self.graphsContentView.bottomAnchor)
        ])
        
        self.graphsContentView.addSubview(self.tasksProgressDailyGraphView)
        NSLayoutConstraint.activate([
            self.tasksProgressDailyGraphView.topAnchor.constraint(equalTo: self.graphsContentView.topAnchor),
            self.tasksProgressDailyGraphView.leadingAnchor.constraint(equalTo: self.timelineDailyGraphView.trailingAnchor),
            self.tasksProgressDailyGraphView.bottomAnchor.constraint(equalTo: self.graphsContentView.bottomAnchor),
            self.tasksProgressDailyGraphView.trailingAnchor.constraint(equalTo: self.graphsContentView.trailingAnchor)
        ])
    }
    
    private func configureCheckGraphs() {
        (0...2).forEach { idx in
            let button = CheckGraphButton()
            button.addAction(UIAction(handler: { [weak self] _ in
                button.isSelected.toggle()
                self?.selectGraph(index: idx)
            }), for: .touchUpInside)
            self.checkGraphButtons.append(button)
        }
        
        self.graphsContentView.addSubview(self.checkGraphButtons[0])
        NSLayoutConstraint.activate([
            self.checkGraphButtons[0].topAnchor.constraint(equalTo: self.standardDailyGraphView.topAnchor, constant: 73),
            self.checkGraphButtons[0].leadingAnchor.constraint(equalTo: self.standardDailyGraphView.leadingAnchor, constant: 25)
        ])
        
        self.graphsContentView.addSubview(self.checkGraphButtons[1])
        NSLayoutConstraint.activate([
            self.checkGraphButtons[1].topAnchor.constraint(equalTo: self.timelineDailyGraphView.topAnchor, constant: 25),
            self.checkGraphButtons[1].leadingAnchor.constraint(equalTo: self.timelineDailyGraphView.leadingAnchor, constant: 25)
        ])
        
        self.graphsContentView.addSubview(self.checkGraphButtons[2])
        NSLayoutConstraint.activate([
            self.checkGraphButtons[2].topAnchor.constraint(equalTo: self.tasksProgressDailyGraphView.topAnchor, constant: 25),
            self.checkGraphButtons[2].leadingAnchor.constraint(equalTo: self.tasksProgressDailyGraphView.leadingAnchor, constant: 25)
        ])
    }
    
    private func configureTimelineHostingVC() {
        let hostingController = UIHostingController(rootView: TimelineView(frameHeight: 100, viewModel: self.timelineVM))
        addChild(hostingController)
        hostingController.didMove(toParent: self)
        
        self.standardDailyGraphView.configureTimelineLayout(hostingController.view)
    }
}

extension DailysVC {
    private func updateGraphs() {
        self.standardDailyGraphView.updateFromDaily(self.currentDaily)
    }
    
    private func selectGraph(index: Int) {
        // select 로직 구현
        print(index)
    }
}

extension DailysVC: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if RecordController.shared.dailys.dates.contains(date),
           let targetIndex = RecordController.shared.dailys.dates.firstIndex(of: date) {
            self.currentDaily = RecordController.shared.dailys.dailys[targetIndex]
        } else {
            self.currentDaily = nil
        }
    }
}

extension DailysVC: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return RecordController.shared.dailys.dates.contains(date) ? 1 : 0
    }
}

extension DailysVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.graphsScrollView else { return }
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        self.graphsPageControl.currentPage = Int(round(value))
    }
}