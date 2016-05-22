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
    @IBOutlet weak var log_text: NSScrollView!
    
    private var tc : TimerControl = TimerControl(_work_time: 2, _rest_time: 2)
    
    override init() {
        NSLog("AppDelegate::init()")
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        NSLog("AppDelegate::applicationDidFinishLaunching()")

        
        tc.start(log_text)
        setStopButton()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func startButtonClick(sender: AnyObject) {
        NSLog("AppDelegate::startButtonClick()")
        tc.start(log_text)
        setStopButton()
    }
    
    @IBAction func stopButtonClick(sender: AnyObject) {
        NSLog("AppDelegate::stopButtonClick()")
        tc.stop()
        setStartButton()
    }
    
    func setStartButton() {
        stopButton.enabled = false
        startButton.enabled = true
    }
    
    func setStopButton() {
        startButton.enabled = false
        stopButton.enabled = true
    }
}

