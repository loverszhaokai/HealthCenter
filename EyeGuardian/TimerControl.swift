//
//  TimerControl.swift
//  EyeGuardian
//
//  Created by zhaokai on 5/22/16.
//  Copyright © 2016 zhaokai. All rights reserved.
//

import Cocoa

class TimerControl: NSObject {

    private var _work_time_interval : NSTimeInterval = 5
    private var _rest_time_interval : NSTimeInterval = 2
    private var work_timer : NSTimer = NSTimer()
    private var rest_timer : NSTimer = NSTimer()
    
    var work_time_interval: NSTimeInterval {
        get {
            return _work_time_interval
        }
        set {
            _work_time_interval = newValue
            NSUserDefaults.standardUserDefaults().setObject(_work_time_interval, forKey: "work_time_interval")
        }
    }

    var rest_time_interval : NSTimeInterval {
        get {
            return _rest_time_interval
        }
        set {
            _rest_time_interval = newValue
            NSUserDefaults.standardUserDefaults().setObject(_rest_time_interval, forKey: "rest_time_interval")
        }
    }

    func start(sv : NSScrollView) {
        NSLog("TimerControl::start()")

        work_timer = NSTimer.scheduledTimerWithTimeInterval(_work_time_interval, target: self, selector: "restStart:", userInfo: ["sv": sv], repeats: false)
        addToScrollView(sv, text: "TimerControl log:\n")
        addToScrollView(sv, text: "\t >> start to work, _work_time_interval=\(_work_time_interval)\n")
    }
    
    func stop() {
        work_timer.invalidate()
        rest_timer.invalidate()
    }

    func workStart(timer: NSTimer) {
        NSLog("TimerControl::workStart(timer) start to work")
        let dict = timer.userInfo as! NSDictionary
        work_timer = NSTimer.scheduledTimerWithTimeInterval(_work_time_interval, target: self, selector: "restStart:", userInfo: ["sv": dict["sv"]!], repeats: false)
        addToScrollView(dict["sv"] as! NSScrollView, text: "\t >> start to work, _work_time_interval=\(_work_time_interval)\n")
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.work()
    }
    
    func restStart(timer: NSTimer) {
        NSLog("TimerControl::restStart(timer) start to rest")
        let dict = timer.userInfo as! NSDictionary
        rest_timer = NSTimer.scheduledTimerWithTimeInterval(_rest_time_interval, target: self, selector: "workStart:", userInfo: ["sv": dict["sv"]!], repeats: false)
        NSRunLoop.currentRunLoop().addTimer(rest_timer, forMode: NSRunLoopCommonModes)
        addToScrollView(dict["sv"] as! NSScrollView, text: "\t << start to rest, _rest_time_interval=\(_rest_time_interval)\n\n")
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.rest()
    }
    
    func addToScrollView(sv: NSScrollView, text: String) {
        let textView = sv.documentView as! NSTextView
        textView.string?.appendContentsOf(text)
    }
}
