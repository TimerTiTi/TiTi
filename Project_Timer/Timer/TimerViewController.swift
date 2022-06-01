//
//  TimerViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/04/30.
//  Copyright © 2021 FDEE. All rights reserved.
//

import UIKit
import Combine
import AudioToolbox
import AVFoundation

class TimerViewController: UIViewController {
    static let identifier = "TimerViewController"

    @IBOutlet var taskButton: UIButton!
    @IBOutlet var innerProgress: CircularProgressView!
    @IBOutlet var outterProgress: CircularProgressView!
    
    @IBOutlet var sumTimeLabel: UILabel!
    @IBOutlet var TIMEofSum: UILabel!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var TIMEofTimer: UILabel!
    @IBOutlet var targetTimeLabel: UILabel!
    @IBOutlet var TIMEofTarget: UILabel!
    @IBOutlet var finishTimeLabel: UILabel!
    
    @IBOutlet var startStopBT: UIButton!
    @IBOutlet var startStopBTLabel: UILabel!
    @IBOutlet var setTimerBT: UIButton!
    @IBOutlet var settingBT: UIButton!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var warningRecordDate: UIButton!
    
    let BLUE = UIColor(named: "Blue")
    let RED = UIColor(named: "Text")
    let INNER = UIColor(named: "innerColor")
    let startButtonColor = UIColor(named: "startButtonColor")
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: TimerVM?
    
    var progressPer: Float = 0.0
    var progressPeriod: Int = 0
    var innerProgressPer: Float = 0.0
    var isLandcape: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLocalizable()
        self.configureShadow()
        self.configureProgress()
        self.configureObservation()
        self.setStopColor()
        self.setButtonsEnabledTrue()
        self.configureViewModel()
        self.bindAll()
        self.viewModel?.updateTask()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = .white
        self.viewModel?.updateTask()
        self.viewModel?.updateModeNum()
        self.viewModel?.updateTimes()
        self.viewModel?.updateDaily()
    }

    @IBAction func taskSelect(_ sender: Any) {
        self.showTaskSelectVC()
    }
    
    @IBAction func timerStartStopAction(_ sender: Any) {
        guard self.viewModel?.task ?? "none" != "none" else {
            self.showTaskWarningAlert()
            return
        }
        self.viewModel?.timerAction()
    }
    
    @IBAction func setting(_ sender: Any) {
        self.showSettingView()
    }
    // MARK: 차기 업데이트시 viewModel?.timerReset 으로 수정 예정
    @IBAction func reset(_ sender: Any) {
        self.showSettingTimerView()
    }
    
    @IBAction func showRecordDateAlert(_ sender: Any) {
        self.showRecordDateWarning(title: "Check the date of recording".localized(), text: "Do you want to start the New record?".localized()) { [weak self] in
            self?.showSettingView()
        }
    }
}

// MARK: - Configure
extension TimerViewController {
    private func configureLocalizable() {
        self.sumTimeLabel.text = "Sum Time".localized()
        self.timerLabel.text = "Timer".localized()
        self.targetTimeLabel.text = "Target Time".localized()
    }
    private func configureShadow() {
        self.setTimerBT.configureShadow(opacity: 0.5, radius: 4)
        self.settingBT.configureShadow(opacity: 0.5, radius: 4)
        self.TIMEofSum.configureShadow(opacity: 0.6, radius: 2)
        self.TIMEofTimer.configureShadow(opacity: 0.6, radius: 2)
        self.TIMEofTarget.configureShadow(opacity: 0.6, radius: 2)
    }
    private func configureProgress() {
        self.outterProgress.progressWidth = 20.0
        self.outterProgress.trackColor = UIColor.darkGray
        self.innerProgress.progressWidth = 8.0
        self.innerProgress.trackColor = UIColor.clear
    }
    private func configureObservation() {
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(forName: .removeNewRecordWarning, object: nil, queue: .main) { [weak self] _ in
            self?.hideWarningRecordDate()
        }
    }
    private func configureViewModel() {
        self.viewModel = TimerVM()
    }
}

// MARK: - IBAction
extension TimerViewController {
    private func showTaskSelectVC() {
        guard let setVC = storyboard?.instantiateViewController(withIdentifier: taskSelectViewController.identifier) as? taskSelectViewController else { return }
        setVC.delegate = self
        present(setVC, animated: true, completion: nil)
    }
    private func showSettingView() {
        guard let setVC = storyboard?.instantiateViewController(withIdentifier: SetViewController.identifier) as? SetViewController else { return }
        setVC.delegate = self
        present(setVC, animated: true, completion: nil)
    }
    private func showSettingTimerView() {
        guard let setTimerVC = storyboard?.instantiateViewController(withIdentifier: SetTimerViewController.identifier) as? SetTimerViewController else { return }
        setTimerVC.delegate = self
        present(setTimerVC, animated: true, completion: nil)
    }
}

// MARK: - binding
extension TimerViewController {
    private func bindAll() {
        self.bindTimes()
        self.bindDaily()
        self.bindTask()
        self.bindUI()
        self.bindSound()
        self.bindWaringNewDate()
    }
    private func bindTimes() {
        self.viewModel?.$times
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] times in
                self?.updateTIMELabels(times: times)
                self?.updateEndTime(goalTime: times.goal)
                self?.updateProgress(times: times)
                self?.updateRunningColor(times: times)
            })
            .store(in: &self.cancellables)
    }
    private func bindDaily() {
        self.viewModel?.$daily
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] daily in
                self?.updateToday(to: daily.day)
            })
            .store(in: &self.cancellables)
    }
    private func bindTask() {
        self.viewModel?.$task
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] task in
                self?.updateTask(to: task)
            })
            .store(in: &self.cancellables)
    }
    private func bindUI() {
        self.viewModel?.$runningUI
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] runningUI in
                if runningUI {
                    NotificationCenter.default.post(name: .removeNewRecordWarning, object: nil)
                    self?.setStartColor()
                    self?.setButtonsEnabledFalse()
                } else {
                    self?.setStopColor()
                    self?.setButtonsEnabledTrue()
                }
            })
            .store(in: &self.cancellables)
    }
    private func bindSound() {
        self.viewModel?.$soundAlert
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] alert in
                guard alert else { return }
                self?.playSound()
            })
            .store(in: &self.cancellables)
    }
    private func bindWaringNewDate() {
        self.viewModel?.$warningNewDate
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] warning in
                guard warning else { return }
                self?.showWarningRecordDate()
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - logic
extension TimerViewController {
    private func updateTask(to task: String) {
        if task == "none" {
            self.taskButton.setTitle("Enter a new subject".localized(), for: .normal)
            self.setTaskWarningColor()
        } else {
            self.taskButton.setTitle(task, for: .normal)
            if self.viewModel?.runningUI == false {
                self.setTaskWhiteColor()
            }
        }
    }
    
    private func setTaskWarningColor() {
        self.taskButton.setTitleColor(UIColor(named: "lightPink"), for: .normal)
        self.taskButton.layer.borderColor = UIColor(named: "lightPink")?.cgColor
    }
    
    private func setTaskWhiteColor() {
        self.taskButton.setTitleColor(UIColor.white, for: .normal)
        self.taskButton.layer.borderColor = UIColor.white.cgColor
    }
    
    private func updateTIMELabels(times: Times) {
        self.TIMEofSum.text = times.sum.toTimeString
        let timerText = times.timer == 0 ? "FINISH".localized() : times.timer.toTimeString
        self.TIMEofTimer.text = timerText
        self.TIMEofTarget.text = times.goal.toTimeString
    }
    
    private func updateEndTime(goalTime: Int) {
        let endAt = Date().addingTimeInterval(TimeInterval(goalTime))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "hh:mm a"
        let endTime = dateFormatter.string(from: endAt)
        self.finishTimeLabel.text = "To " + endTime
    }
    
    private func updateToday(to date: Date) {
        self.todayLabel.text = date.YYYYMMDDstyleString
    }
    
    private func setStartColor() {
        self.view.backgroundColor = UIColor.black
        outterProgress.progressColor = BLUE!
        innerProgress.progressColor = UIColor.white
        startStopBT.backgroundColor = UIColor.clear
        TIMEofTimer.textColor = BLUE
        //예상종료시간 숨기기, stop 버튼 센터로 이동
        UIView.animate(withDuration: 0.3, animations: {
            self.setTimerBT.alpha = 0
            self.settingBT.alpha = 0
            self.taskButton.layer.borderColor = UIColor.clear.cgColor
            self.startStopBTLabel.textColor = self.RED!
            self.startStopBT.layer.borderColor = UIColor.clear.cgColor
            self.startStopBTLabel.text = "◼︎"
            self.tabBarController?.tabBar.isHidden = true
            self.todayLabel.alpha = 0
        })
    }
    
    private func setButtonsEnabledFalse() {
        self.settingBT.isUserInteractionEnabled = false
        self.setTimerBT.isUserInteractionEnabled = false
        self.taskButton.isUserInteractionEnabled = false
    }
    
    private func setStopColor() {
        self.view.backgroundColor = BLUE
        outterProgress.progressColor = UIColor.white
        innerProgress.progressColor = INNER!
        startStopBT.backgroundColor = startButtonColor!
        TIMEofTimer.textColor = UIColor.white
        //예상종료시간 보이기, stop 버튼 제자리로 이동
        UIView.animate(withDuration: 0.3, animations: {
            self.setTimerBT.alpha = 1
            self.settingBT.alpha = 1
            self.taskButton.layer.borderColor = UIColor.white.cgColor
            self.startStopBTLabel.textColor = UIColor.white
            self.startStopBT.layer.borderColor = self.startButtonColor?.cgColor
            self.startStopBTLabel.text = "▶︎"
            self.tabBarController?.tabBar.isHidden = false
        })
        //animation test
        if(!isLandcape) {
            UIView.animate(withDuration: 0.5, animations: {
                self.taskButton.alpha = 1
                self.todayLabel.alpha = 1
            })
        }
    }
    
    private func setButtonsEnabledTrue() {
        self.settingBT.isUserInteractionEnabled = true
        self.setTimerBT.isUserInteractionEnabled = true
        self.taskButton.isUserInteractionEnabled = true
    }
    
    private func updateProgress(times: Times) {
        let timerPeriod = self.viewModel?.settedTimerTime ?? 2400
        let goalPeriod = self.viewModel?.settedGoalTime ?? 21600
        
        let newProgressPer = Float(timerPeriod - times.timer) / Float(timerPeriod-1)
        self.outterProgress.setProgress(duration: 1.0, value: newProgressPer, from: self.progressPer)
        self.progressPer = newProgressPer
        
        let newInnerProgressPer = Float(times.sum) / Float(goalPeriod)
        self.innerProgress.setProgress(duration: 1.0, value: newInnerProgressPer, from: self.innerProgressPer)
        self.innerProgressPer = newInnerProgressPer
    }
    
    private func printTimes(with times: Times) {
        print("sum: \(times.sum.toTimeString)")
        print("timer: \(times.timer.toTimeString)")
        print("goal: \(times.goal.toTimeString)")
    }
    
    private func updateRunningColor(times: Times) {
        guard self.viewModel?.runningUI == true,
              times.timer < 60 else { return }
        self.TIMEofTimer.textColor = RED
        self.outterProgress.progressColor = RED!
    }
    
    private func playSound() {
        print("play sound")
        guard let url = Bundle.main.url(forResource: "timer", withExtension: "mp3") else {
            print("error to get the mp3 file")
            return
        }
        let player = AVPlayer(url: url)
        player.play()
    }
    
    private func showWarningRecordDate() {
        UIView.animate(withDuration: 0.15) {
            self.warningRecordDate.alpha = 1
            self.todayLabel.textColor = self.RED!
        }
    }
    
    private func hideWarningRecordDate() {
        UIView.animate(withDuration: 0.15) {
            self.warningRecordDate.alpha = 0
            self.todayLabel.textColor = .white
        }
    }
}

// MARK: - Rotation
extension TimerViewController {
    @objc func deviceRotated(){
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        if UIDevice.current.orientation.isLandscape {
            self.setLandscape()
        } else {
            self.setPortrait()
        }
    }
    
    private func setLandscape() {
        if self.viewModel?.runningUI ?? false == false {
            UIView.animate(withDuration: 0.3) {
                self.taskButton.alpha = 0
                self.todayLabel.alpha = 0
            }
        }
        self.isLandcape = true
    }
    
    private func setPortrait() {
        if self.viewModel?.runningUI ?? false == false {
            UIView.animate(withDuration: 0.3) {
                self.taskButton.alpha = 1
                self.todayLabel.alpha = 1
            }
        }
        self.isLandcape = false
    }
}

// MARK: Background
extension TimerViewController {
    @objc func pauseWhenBackground(noti: Notification) {
        guard let running = self.viewModel?.runningUI,
              running == true else { return }
        self.viewModel?.enterBackground()
    }
    
    @objc func willEnterForeground(noti: Notification) {
        guard let running = self.viewModel?.runningUI,
              running == true else { return }
        self.viewModel?.enterForground()
    }
}

extension TimerViewController: NewRecordCreatable {
    func newRecord() {
        self.viewModel?.newRecord()
        NotificationCenter.default.post(name: .removeNewRecordWarning, object: nil)
    }
}

extension TimerViewController: TaskChangeable {
    func selectTask(to task: String) {
        self.viewModel?.changeTask(to: task)
    }
}
// MARK: 추후 Setting 에서 수시로 수정시 사용될 부분
extension TimerViewController: TimerTimeSettable {
    func updateTimerTime(to timer: Int) {
        self.viewModel?.updateTimerTime(to: timer)
    }
}

extension TimerViewController {
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
