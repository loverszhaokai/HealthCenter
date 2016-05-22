//
//  AppDelegate.swift
//  EyeGuardian
//
//  Created by zhaokai on 5/22/16.
//  Copyright © 2016 zhaokai. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var skipButton: NSButton!

    @IBOutlet weak var log_text: NSScrollView!
    @IBOutlet weak var workTimeText: NSTextField!
    @IBOutlet weak var restTimeText: NSTextField!

    let skipWindow = NSWindow()
    
    private var tc : TimerControl = TimerControl()
    
    override init() {
        NSLog("AppDelegate::init()")
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        NSLog("AppDelegate::applicationDidFinishLaunching()")
        
        initSkipWindow()
        SetTimeIntervalFromUserDefault()
        tc.start(log_text)
        setStopButton()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func startButtonClick(sender: AnyObject) {
        NSLog("AppDelegate::startButtonClick()")
        SetTimeInterval()
        tc.start(log_text)
        setStopButton()
    }
    
    @IBAction func stopButtonClick(sender: AnyObject) {
        NSLog("AppDelegate::stopButtonClick()")
        tc.stop()
        setStartButton()
    }
    
    @IBAction func workTimeTextChanged(sender: AnyObject) {
        NSLog("AppDelegate::workTimeTextChanged()")
    }
    
    @IBAction func restTimeTextChanged(sender: AnyObject) {
        NSLog("AppDelegate::restTimeTextChanged()")
    }
    
    @IBAction func skipButtonClick(sender: AnyObject) {
        NSLog("AppDelegate::skipButtonClick()")
        
        work()
        tc.stop()
        tc.start(log_text)
        setStopButton()
    }
    
    func setStartButton() {
        stopButton.enabled = false
        startButton.enabled = true
    }
    
    func setStopButton() {
        startButton.enabled = false
        stopButton.enabled = true
    }
    
    func SetTimeInterval() {
        NSLog("AppDelegate::GetTimeInterval()")
        NSLog("work_time_text=\(workTimeText.stringValue)")
        NSLog("rest_time_text=\(restTimeText.stringValue)")
        let work_time_interval : Double = Double(workTimeText.stringValue)!
        let rest_time_interval : Double = Double(restTimeText.stringValue)!
        
        if (work_time_interval > 0) {
            tc.work_time_interval = work_time_interval
        }

        if (rest_time_interval > 0) {
            tc.rest_time_interval = rest_time_interval
        }
    }
    
    private func SetTimeIntervalFromUserDefault() {
        let work_time_interval = NSUserDefaults.standardUserDefaults().floatForKey("work_time_interval")
        let rest_time_interval = NSUserDefaults.standardUserDefaults().floatForKey("rest_time_interval")

        if (work_time_interval > 0) {
            tc.work_time_interval = NSTimeInterval(work_time_interval)
        }
        workTimeText.stringValue = String(tc.work_time_interval);
        
        if (rest_time_interval > 0) {
            tc.rest_time_interval = NSTimeInterval(rest_time_interval)
        }
        restTimeText.stringValue = String(tc.rest_time_interval)
        
        NSLog(">>>> [config] work_time_interval=\(work_time_interval), rest_time_interval=\(rest_time_interval)")
    }
    
    func initSkipWindow() {
        let rect : NSRect = NSScreen.mainScreen()!.frame
        let windowWidth : CGFloat = 300;
        let windowHeight : CGFloat = 200;
        let windowXPos = (rect.width - windowWidth) / 2
        let windowYPos = (rect.height - windowHeight) / 2
        
        skipWindow.setFrame(NSRect(x: windowXPos, y: windowYPos, width: windowWidth, height: windowHeight), display: true)
        
        let skipWidth = skipButton.frame.width
        let skipHeight = skipButton.frame.height
        let skipXPos = (windowWidth - skipWidth) / 2
        let skipYPos = (windowHeight - skipHeight) / 2

        skipButton.setFrameOrigin(NSPoint(x: skipXPos, y: skipYPos))
        skipWindow.contentView?.addSubview(skipButton)
    }
    
    func rest() {
        skipWindow.setIsVisible(true)
    }
    
    func work() {
        skipWindow.setIsVisible(false)
    }
}

