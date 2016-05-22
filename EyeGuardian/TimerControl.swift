//
//  TimerControl.swift
//  EyeGuardian
//
//  Created by zhaokai on 5/22/16.
//  Copyright © 2016 zhaokai. All rights reserved.
//

import Cocoa

class TimerControl: NSObject {

    private var work_time : NSTimeInterval
    private var rest_time : NSTimeInterval
    private var timer_work : NSTimer = NSTimer()
    private var timer_rest : NSTimer = NSTimer()
    
    init(_work_time : NSTimeInterval, _rest_time : NSTimeInterval) {
        self.work_time = _work_time
        self.rest_time = _rest_time
        
        NSLog("init() work_time=\(work_time) rest_time=\(rest_time)")
    }
    
    func setWorkTime(_work_time : NSTimeInterval) {
        self.work_time = _work_time
    }
    
    func setRestTime(_rest_time : NSTimeInterval) {
        self.rest_time = _rest_time
    }
    
    func addToScrollView(sv: NSScrollView, text: String) {
        let textView = sv.documentView as! NSTextView
        textView.string?.appendContentsOf(text)
    }

    func start(sv : NSScrollView) {
        NSLog("TimerControl::start()")

        timer_work = NSTimer.scheduledTimerWithTimeInterval(work_time, target: self, selector: "restStart:", userInfo: ["sv": sv], repeats: false)
        addToScrollView(sv, text: "TimerControl log:\n")
    }
    
    func stop() {
        timer_work.invalidate()
        timer_rest.invalidate()
    }

    func workStart(timer: NSTimer) {
        NSLog("TimerControl::workStart(timer) start to work")
        let dict = timer.userInfo as! NSDictionary
        timer_work = NSTimer.scheduledTimerWithTimeInterval(work_time, target: self, selector: "restStart:", userInfo: ["sv": dict["sv"]!], repeats: false)
        addToScrollView(dict["sv"] as! NSScrollView, text: "\t >>start to work, work_time=\(work_time)\n")
    }
    
    func restStart(timer: NSTimer) {
        NSLog("TimerControl::restStart(timer) start to rest")
        let dict = timer.userInfo as! NSDictionary
        timer_rest = NSTimer.scheduledTimerWithTimeInterval(rest_time, target: self, selector: "workStart:", userInfo: ["sv": dict["sv"]!], repeats: false)
        addToScrollView(dict["sv"] as! NSScrollView, text: "\t ::start to rest, rest time=\(rest_time)\n\n")
    }
}
