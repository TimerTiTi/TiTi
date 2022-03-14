//
//  LogViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2020/09/28.
//  Copyright © 2020 FDEE. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
//        setDummyData()
    }
}


extension LogViewController {
    
    func setData() {
        Label_day1.text = UserDefaults.standard.value(forKey: "day1") as? String ?? "NO DATA"
        Label_day2.text = UserDefaults.standard.value(forKey: "day2") as? String ?? "NO DATA"
        Label_day3.text = UserDefaults.standard.value(forKey: "day3") as? String ?? "NO DATA"
        Label_day4.text = UserDefaults.standard.value(forKey: "day4") as? String ?? "NO DATA"
        Label_day5.text = UserDefaults.standard.value(forKey: "day5") as? String ?? "NO DATA"
        Label_day6.text = UserDefaults.standard.value(forKey: "day6") as? String ?? "NO DATA"
        Label_day7.text = UserDefaults.standard.value(forKey: "day7") as? String ?? "NO DATA"
        Label_time1.text = UserDefaults.standard.value(forKey: "time1") as? String ?? "NO DATA"
        Label_time2.text = UserDefaults.standard.value(forKey: "time2") as? String ?? "NO DATA"
        Label_time3.text = UserDefaults.standard.value(forKey: "time3") as? String ?? "NO DATA"
        Label_time4.text = UserDefaults.standard.value(forKey: "time4") as? String ?? "NO DATA"
        Label_time5.text = UserDefaults.standard.value(forKey: "time5") as? String ?? "NO DATA"
        Label_time6.text = UserDefaults.standard.value(forKey: "time6") as? String ?? "NO DATA"
        Label_time7.text = UserDefaults.standard.value(forKey: "time7") as? String ?? "NO DATA"
    }
    
    func setDummyData() {
        Label_day1.text = "1월 20일"
        Label_day2.text = "1월 19일"
        Label_day3.text = "1월 18일"
        Label_day4.text = "1월 17일"
        Label_day5.text = "1월 16일"
        Label_day6.text = "1월 15일"
        Label_day7.text = "1월 14일"
        Label_time1.text = "3:23:10"
        Label_time2.text = "4:03:41"
        Label_time3.text = "6:08:14"
        Label_time4.text = "4:03:39"
        Label_time5.text = "5:44:07"
        Label_time6.text = "4:58:23"
        Label_time7.text = "3:37:20"
    }
    
    func printTime(temp : Int) -> String {
        var returnString = "";
        var num = temp;
        if(num < 0) {
            num = -num;
            returnString += "+";
        }
        let S = num%60
        let H = num/3600
        let M = num/60 - H*60
        
        let stringS = S<10 ? "0"+String(S) : String(S)
        let stringM = M<10 ? "0"+String(M) : String(M)
        
        returnString += String(H) + ":" + stringM + ":" + stringS
        return returnString
    }
}
