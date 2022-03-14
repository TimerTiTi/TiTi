//
//  LogViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2020/09/28.
//  Copyright © 2020 FDEE. All rights reserved.
//

import UIKit

class LogViewController_test: UIViewController {

    @IBOutlet var Label_day1: UILabel!
    @IBOutlet var Label_day2: UILabel!
    @IBOutlet var Label_day3: UILabel!
    @IBOutlet var Label_day4: UILabel!
    @IBOutlet var Label_day5: UILabel!
    @IBOutlet var Label_day6: UILabel!
    @IBOutlet var Label_day7: UILabel!
    
    @IBOutlet var Label_time1: UILabel!
    @IBOutlet var Label_time2: UILabel!
    @IBOutlet var Label_time3: UILabel!
    @IBOutlet var Label_time4: UILabel!
    @IBOutlet var Label_time5: UILabel!
    @IBOutlet var Label_time6: UILabel!
    @IBOutlet var Label_time7: UILabel!
    
    @IBOutlet var Label_break1: UILabel!
    @IBOutlet var Label_break2: UILabel!
    @IBOutlet var Label_break3: UILabel!
    @IBOutlet var Label_break4: UILabel!
    @IBOutlet var Label_break5: UILabel!
    @IBOutlet var Label_break6: UILabel!
    @IBOutlet var Label_break7: UILabel!
    
    @IBOutlet var studyTitle: UILabel!
    @IBOutlet var studyL1: UILabel!
    @IBOutlet var studyL2: UILabel!
    @IBOutlet var studyL3: UILabel!
    @IBOutlet var studyL4: UILabel!
    @IBOutlet var studyL5: UILabel!
    @IBOutlet var studyL6: UILabel!
    @IBOutlet var studyL7: UILabel!
    
    @IBOutlet var restL1: UILabel!
    @IBOutlet var restL2: UILabel!
    @IBOutlet var restL3: UILabel!
    @IBOutlet var restL4: UILabel!
    @IBOutlet var restL5: UILabel!
    @IBOutlet var restL6: UILabel!
    @IBOutlet var restL7: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocalizable()
        setData()
//        setDummyData()
    }
}


extension LogViewController_test {
    
    func setData() {
        Label_day1.text = translate(input: UserDefaults.standard.value(forKey: "day1") as? String ?? "NO DATA")
        Label_day2.text = translate(input: UserDefaults.standard.value(forKey: "day2") as? String ?? "NO DATA")
        Label_day3.text = translate(input: UserDefaults.standard.value(forKey: "day3") as? String ?? "NO DATA")
        Label_day4.text = translate(input: UserDefaults.standard.value(forKey: "day4") as? String ?? "NO DATA")
        Label_day5.text = translate(input: UserDefaults.standard.value(forKey: "day5") as? String ?? "NO DATA")
        Label_day6.text = translate(input: UserDefaults.standard.value(forKey: "day6") as? String ?? "NO DATA")
        Label_day7.text = translate(input: UserDefaults.standard.value(forKey: "day7") as? String ?? "NO DATA")
        
        Label_time1.text = UserDefaults.standard.value(forKey: "time1") as? String ?? "NO DATA"
        Label_time2.text = UserDefaults.standard.value(forKey: "time2") as? String ?? "NO DATA"
        Label_time3.text = UserDefaults.standard.value(forKey: "time3") as? String ?? "NO DATA"
        Label_time4.text = UserDefaults.standard.value(forKey: "time4") as? String ?? "NO DATA"
        Label_time5.text = UserDefaults.standard.value(forKey: "time5") as? String ?? "NO DATA"
        Label_time6.text = UserDefaults.standard.value(forKey: "time6") as? String ?? "NO DATA"
        Label_time7.text = UserDefaults.standard.value(forKey: "time7") as? String ?? "NO DATA"
        
        Label_break1.text = UserDefaults.standard.value(forKey: "break1") as? String ?? "NO DATA"
        Label_break2.text = UserDefaults.standard.value(forKey: "break2") as? String ?? "NO DATA"
        Label_break3.text = UserDefaults.standard.value(forKey: "break3") as? String ?? "NO DATA"
        Label_break4.text = UserDefaults.standard.value(forKey: "break4") as? String ?? "NO DATA"
        Label_break5.text = UserDefaults.standard.value(forKey: "break5") as? String ?? "NO DATA"
        Label_break6.text = UserDefaults.standard.value(forKey: "break6") as? String ?? "NO DATA"
        Label_break7.text = UserDefaults.standard.value(forKey: "break7") as? String ?? "NO DATA"
    }
    
    func setDummyData() {
        Label_day1.text = "2/24"
        Label_day2.text = "2/23"
        Label_day3.text = "2/22"
        Label_day4.text = "2/21"
        Label_day5.text = "2/20"
        Label_day6.text = "2/19"
        Label_day7.text = "2/18"

        Label_time1.text = "2:35:20"
        Label_time2.text = "4:03:41"
        Label_time3.text = "6:08:14"
        Label_time4.text = "4:03:39"
        Label_time5.text = "5:44:07"
        Label_time6.text = "4:58:23"
        Label_time7.text = "3:37:20"
        
        Label_break1.text = "0:35:20"
        Label_break2.text = "2:01:00"
        Label_break3.text = "2:32:56"
        Label_break4.text = "1:05:00"
        Label_break5.text = "1:40:08"
        Label_break6.text = "2:02:15"
        Label_break7.text = "0:37:50"
    }
    
    func translate(input: String) -> String {
        if(input == "NO DATA") {
            return "-/-"
        } else {
            print(input)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M월 d일"
            let exported = dateFormatter.date(from: input)!
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "M/d"
            return newDateFormatter.string(from: exported)
        }
    }
    
    func setLocalizable() {
        studyTitle.text = "Study Records".localized()
        studyL1.text = "Study :".localized()
        studyL2.text = "Study :".localized()
        studyL3.text = "Study :".localized()
        studyL4.text = "Study :".localized()
        studyL5.text = "Study :".localized()
        studyL6.text = "Study :".localized()
        studyL7.text = "Study :".localized()
        restL1.text = "Rest :".localized()
        restL2.text = "Rest :".localized()
        restL3.text = "Rest :".localized()
        restL4.text = "Rest :".localized()
        restL5.text = "Rest :".localized()
        restL6.text = "Rest :".localized()
        restL7.text = "Rest :".localized()
    }
}
