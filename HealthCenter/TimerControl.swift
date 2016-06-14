//
//  TimerControl.swift
//  HealthCenter
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
        updateLastRestTimeProgress()
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
        updateLastRestTimeProgress()
        rest_timer = NSTimer.scheduledTimerWithTimeInterval(_rest_time_interval, target: self, selector: "workStart", userInfo: nil, repeats: false)
        appDelegate.rest()
    }

    func realWorkStart() {
        NSLog("TimerControl::realWorkStart() _real_work_time_interval=\(_real_work_time_interval)")
        stop()
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        updateLastTimeMenuLabel()
        work_timer = NSTimer.scheduledTimerWithTimeInterval(_real_work_time_interval, target: self, selector: "restStart", userInfo: nil, repeats: false)
        appDelegate.work()
    }
    
    func updateLastTimeMenuLabel() {
        last_current_time = 0
        last_total_time = _real_work_time_interval
        last_time_timer.invalidate()
        last_time_timer = NSTimer.scheduledTimerWithTimeInterval(LAST_TIME_INTERVAL, target: self, selector: "updateLastTimeMenuLabelPerSecond", userInfo: nil, repeats: true)
    }
    
    func updateLastTimeMenuLabelPerSecond() {
        last_current_time++
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.lastTimeMenuLabel.title = getFormatTime(Int(last_total_time - last_current_time)) + " until rest"
    }
    
    func updateLastRestTimeProgress() {
        last_current_time = 0
        last_total_time = _rest_time_interval
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.lastRestTimeProgress.doubleValue = 0
        last_time_timer.invalidate()
        last_time_timer = NSTimer.scheduledTimerWithTimeInterval(LAST_TIME_INTERVAL, target: self, selector: "updateLastRestTimeProgressPerSecond", userInfo: nil, repeats: true)
    }
    
    func updateLastRestTimeProgressPerSecond() {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        last_current_time++
        appDelegate.lastRestTimeProgress.doubleValue = 100 * last_current_time / last_total_time
        appDelegate.lastRestTimeLabel.stringValue = getFormatTime(Int(last_total_time - last_current_time))
        appDelegate.lastRestTimeLabel.sizeToFit()
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
