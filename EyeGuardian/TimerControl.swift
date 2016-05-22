//
//  TimerControl.swift
//  EyeGuardian
//
//  Created by zhaokai on 5/22/16.
//  Copyright © 2016 zhaokai. All rights reserved.
//

import Cocoa

class TimerControl: NSObject, NSApplicationDelegate {

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
   
    func workStart() {
        NSLog("TimerControl::workBegin() start to work")
        timer_work = NSTimer.scheduledTimerWithTimeInterval(work_time, target: self, selector: "restStart", userInfo: nil, repeats: false)
    }

    func restStart() {
        NSLog("TimerControl::restBegin() start to rest")
        timer_rest = NSTimer.scheduledTimerWithTimeInterval(rest_time, target: self, selector: "workStart", userInfo: nil, repeats: false)
    }

    func start() {
        workStart()
    }
    
    func stop() {
        timer_work.invalidate()
        timer_rest.invalidate()
    }
}
