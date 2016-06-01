//
//  TimerControl.swift
//  EyeGuardian
//
//  Created by zhaokai on 5/22/16.
//  Copyright © 2016 zhaokai. All rights reserved.
//

import Cocoa

class TimerControl: NSObject {
    
    let LAST_TIME_INTERVAL : NSTimeInterval = 1
    
    private var _work_time_interval : NSTimeInterval = 50 * 60
    private var _real_work_time_interval : NSTimeInterval = 50 * 60
    private var _rest_time_interval : NSTimeInterval = 5 * 60
    private var _put_off_time_interval : NSTimeInterval = 5 * 60
    
    private var work_timer : NSTimer = NSTimer()
    private var rest_timer : NSTimer = NSTimer()
    private var last_time_timer : NSTimer = NSTimer()
    
    private var last_current_time : Double = 0
    private var last_total_time : Double = 0
    
    var work_time_interval: NSTimeInterval {
        get {
            return _work_time_interval
        }
        set {
            _work_time_interval = newValue
        }
    }
    
    var real_work_time_interval : NSTimeInterval {
        get {
            return _real_work_time_interval
        }
        set {
            _real_work_time_interval = newValue
        }
    }

    var rest_time_interval : NSTimeInterval {
        get {
            return _rest_time_interval
        }
        set {
            _rest_time_interval = newValue
        }
    }
    
    var put_off_time_interval : NSTimeInterval {
        get {
            return _put_off_time_interval
        }
        set {
            _put_off_time_interval = newValue
        }
    }
    
    func startToRest() {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        updateLastTimeProgressAndLabel(false)
        rest_timer = NSTimer.scheduledTimerWithTimeInterval(_rest_time_interval, target: self, selector: "workStart", userInfo: nil, repeats: false)
        appDelegate.rest()
    }
    
    func stop() {
        work_timer.invalidate()
        rest_timer.invalidate()
        last_time_timer.invalidate()
    }

    func workStart() {
        NSLog("TimerControl::workStart(timer) start to work")
        _real_work_time_interval = _work_time_interval
        realWorkStart()
    }
    
    func putOffStart() {
        _real_work_time_interval = _put_off_time_interval
        realWorkStart()
    }
    
    func restStart() {
        NSLog("TimerControl::restStart(timer) start to rest")
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        updateLastTimeProgressAndLabel(false)
        rest_timer = NSTimer.scheduledTimerWithTimeInterval(_rest_time_interval, target: self, selector: "workStart", userInfo: nil, repeats: false)
        appDelegate.rest()
    }

    func realWorkStart() {
        NSLog("TimerControl::realWorkStart() _real_work_time_interval=\(_real_work_time_interval)")
        stop()
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        updateLastTimeProgressAndLabel(true)
        work_timer = NSTimer.scheduledTimerWithTimeInterval(_real_work_time_interval, target: self, selector: "restStart", userInfo: nil, repeats: false)
        appDelegate.work()
    }
    
    func updateLastTimeProgressAndLabel(isWork : Bool) {
        last_current_time = 0
        last_total_time = _real_work_time_interval
        if (!isWork) {
            last_total_time = _rest_time_interval
        }

        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.lastWorkTimeProgress.doubleValue = 0
        appDelegate.lastRestTimeProgress.doubleValue = 0
        var lastTimeProgress : NSProgressIndicator = appDelegate.lastWorkTimeProgress
        var lastTimeLabel : NSTextField = appDelegate.lastWorkTimeLabel
        
        if (!isWork) {
            lastTimeProgress = appDelegate.lastRestTimeProgress
            lastTimeLabel = appDelegate.lastRestTimeLabel
        }

        last_time_timer.invalidate()
        last_time_timer = NSTimer.scheduledTimerWithTimeInterval(LAST_TIME_INTERVAL, target: self, selector: "updateLastTimeProgress:", userInfo: ["lastTimeProgress" : lastTimeProgress, "lastTimeLabel" : lastTimeLabel], repeats: true)
    }
    
    func updateLastTimeProgress(timer : NSTimer) {
        last_current_time++
        NSLog("\t updateLastTimeProgress: last_current_time=\(last_current_time)  last_total_time=\(last_total_time) doublev=\(last_current_time / last_total_time)")
        let dict = timer.userInfo as! NSDictionary
        let lastTimeProgress = dict["lastTimeProgress"] as! NSProgressIndicator
        let lastTimeLabel = dict["lastTimeLabel"] as! NSTextField
        lastTimeProgress.doubleValue = 100 * last_current_time / last_total_time
        lastTimeLabel.stringValue = getFormatTime(Int(last_total_time - last_current_time))
        lastTimeLabel.sizeToFit()
    }
    
    func getFormatTime(var seconds : Int) -> String {
        let hours : Int = seconds / (60 * 60)
        seconds = seconds - hours * 60 * 60
        let minutes : Int = seconds / 60
        seconds = seconds - minutes * 60
        
        var format_time : String = ""
        
        if (hours > 0) {
            format_time.appendContentsOf("\(hours) hour")
            if (hours > 1) {
                format_time.appendContentsOf("s")
            }
        }
        
        if (hours > 0 || minutes > 0) {
            format_time.appendContentsOf(" \(minutes) minute")
            if (minutes > 1) {
                format_time.appendContentsOf("s")
            }
        }
        
        format_time.appendContentsOf(" \(seconds) seconds")
        return format_time
    }
}
