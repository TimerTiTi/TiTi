//
//  ModifyRecordVC.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/08/13.
//  Copyright © 2022 FDEE. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

final class ModifyRecordVC: UIViewController {
    static let identifier = "ModifyRecordVC"
    
    @IBOutlet weak var graphsScrollView: UIScrollView!
    @IBOutlet weak var graphsContentView: UIView!
    @IBOutlet weak var graphsPageControl: UIPageControl!
    private var standardDailyGraphView = StandardDailyGraphView()
    private var timelineDailyGraphView = TimelineDailyGraphView()
    private var tasksProgressDailyGraphView = TasksProgressDailyGraphView()
    private var taskInteractionFrameView = UIView()
    private var taskModifyInteractionView = TaskInteractionView()
    private var taskEmptyInteractionView: UILabel = {
        let label = UILabel()
        label.text = "과목을 선택하여 기록수정 후\nSAVE를 눌러주세요"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = TiTiFont.HGGGothicssiP60g(size: 17)
        label.textColor = UIColor.label
        return label
    }()
    private var isReverseColor: Bool = false    // Daily로부터 받아와야 함
    private var viewModel: ModifyRecordVM?
    private var cancellables: Set<AnyCancellable> = []
    enum GraphCollectionView: Int {
        case standardDailyGraphView = 0
        case tasksProgressDailyGraphView = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ModifyRecordVC"
        self.configureScrollView()
        self.configureTaskInteractionFrameView()
        self.configureGraphs()
        self.configureCollectionViewDelegate()
        self.configureViewModel()
        self.configureHostingVC()
        self.bindAll()
        
        self.viewModel?.updateDaily(to: RecordController.shared.daily)
        self.showTaskModifyInteractionView()
//        self.showTaskEmptyInteractionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureShadows(self.taskModifyInteractionView)
    }
}

extension ModifyRecordVC {
    private func configureShadows(_ views: UIView...) {
        views.forEach { $0.configureShadow() }
    }
    
    private func configureScrollView() {
        self.graphsScrollView.delegate = self
    }
    
    private func configureTaskInteractionFrameView() {
        self.view.addSubview(self.taskInteractionFrameView)
        self.taskInteractionFrameView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.taskInteractionFrameView.widthAnchor.constraint(equalToConstant: 365),
            self.taskInteractionFrameView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.taskInteractionFrameView.topAnchor.constraint(equalTo: self.graphsScrollView.bottomAnchor, constant: 16),
            self.taskInteractionFrameView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16 - (self.tabBarController?.tabBar.frame.height ?? 0))
        ])
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
    
    private func configureCollectionViewDelegate() {
        self.standardDailyGraphView.configureDelegate(self)
        self.tasksProgressDailyGraphView.configureDelegate(self)
    }
    
    private func configureViewModel() {
        self.viewModel = ModifyRecordVM()
    }
    
    private func configureHostingVC() {
        guard let timelineVM = self.viewModel?.timelineVM else { return }
        let hostingStandardVC = UIHostingController(rootView: TimelineView(frameHeight: 100, viewModel: timelineVM))
        addChild(hostingStandardVC)
        hostingStandardVC.didMove(toParent: self)
        
        self.standardDailyGraphView.configureTimelineLayout(hostingStandardVC.view)
        
        let hostingTimelineVC = UIHostingController(rootView: TimelineView(frameHeight: 150, viewModel: timelineVM))
        addChild(hostingTimelineVC)
        hostingTimelineVC.didMove(toParent: self)
        
        self.timelineDailyGraphView.configureTimelineLayout(hostingTimelineVC.view)
    }
}

extension ModifyRecordVC {
    private func bindAll() {
        self.bindDaily()
        self.bindTasks()
    }
    
    private func bindDaily() {
        self.viewModel?.$currentDaily
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.updateGraphsFromDaily()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindTasks() {
        self.viewModel?.$tasks
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.updateGraphsFromTasks()
            })
            .store(in: &self.cancellables)
    }
}

extension ModifyRecordVC {
    private func updateGraphsFromDaily() {
        let daily = self.viewModel?.currentDaily
        self.standardDailyGraphView.updateFromDaily(daily)
        self.timelineDailyGraphView.updateFromDaily(daily)
        self.tasksProgressDailyGraphView.updateFromDaily(daily)
    }
    
    private func updateGraphsFromTasks() {
        let tasks = self.viewModel?.tasks ?? []
        self.standardDailyGraphView.reload()
        self.standardDailyGraphView.layoutIfNeeded()
        self.standardDailyGraphView.progressView.updateProgress(tasks: tasks, width: .small, isReversColor: self.isReverseColor)
        self.tasksProgressDailyGraphView.reload()
        self.tasksProgressDailyGraphView.layoutIfNeeded()
        self.tasksProgressDailyGraphView.progressView.updateProgress(tasks: tasks, width: .medium, isReversColor: self.isReverseColor)
    }
}

extension ModifyRecordVC {
    private func emptyInteractionFrameView() {
        self.taskInteractionFrameView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func showTaskEmptyInteractionView() {
        self.emptyInteractionFrameView()
        
        self.taskInteractionFrameView.addSubview(self.taskEmptyInteractionView)
        self.taskEmptyInteractionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.taskEmptyInteractionView.centerXAnchor.constraint(equalTo: self.taskInteractionFrameView.centerXAnchor),
            self.taskEmptyInteractionView.centerYAnchor.constraint(equalTo: self.taskInteractionFrameView.centerYAnchor)
        ])
    }
    
    private func showTaskModifyInteractionView() {
        self.emptyInteractionFrameView()
        
        self.taskInteractionFrameView.addSubview(self.taskModifyInteractionView)
        self.taskModifyInteractionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.taskModifyInteractionView.centerXAnchor.constraint(equalTo: self.taskInteractionFrameView.centerXAnchor),
            self.taskModifyInteractionView.topAnchor.constraint(equalTo: self.taskInteractionFrameView.topAnchor),
            self.taskModifyInteractionView.bottomAnchor.constraint(equalTo: self.taskInteractionFrameView.bottomAnchor)
        ])
    }
}

extension ModifyRecordVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.graphsScrollView else { return }
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        self.graphsPageControl.currentPage = Int(round(value))
    }
}

extension ModifyRecordVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let graph = GraphCollectionView(rawValue: collectionView.tag) {
            switch graph {
            case .standardDailyGraphView:
                return self.viewModel?.tasks.count ?? 0
            case .tasksProgressDailyGraphView:
                return min(8, self.viewModel?.tasks.count ?? 0)
            }
        } else { return 0 }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let graph = GraphCollectionView(rawValue: collectionView.tag) {
            switch graph {
            case .standardDailyGraphView:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StandardDailyTaskCell.identifier, for: indexPath) as? StandardDailyTaskCell else { return .init() }
                guard let taskInfo = self.viewModel?.tasks[safe: indexPath.item] else { return cell }
                cell.configure(index: indexPath.item, taskInfo: taskInfo, isReversColor: self.isReverseColor)
                return cell
            case .tasksProgressDailyGraphView:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgressDailyTaskCell.identifier, for: indexPath) as? ProgressDailyTaskCell else { return .init() }
                guard let taskInfo = self.viewModel?.tasks[safe: indexPath.item] else { return cell }
                cell.configure(index: indexPath.item, taskInfo: taskInfo, isReversColor: self.isReverseColor)
                return cell
            }
        } else { return .init() }
    }
}

extension ModifyRecordVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let graph = GraphCollectionView(rawValue: collectionView.tag) {
            switch graph {
            case .standardDailyGraphView:
                return CGSize(width: collectionView.bounds.width, height: StandardDailyTaskCell.height)
            case .tasksProgressDailyGraphView:
                return CGSize(width: collectionView.bounds.width, height: ProgressDailyTaskCell.height)
            }
        } else { return .zero }
    }
}