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
    @IBOutlet weak var skipWindow: NSWindow!
    
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var breakNowButton: NSButton!
    @IBOutlet weak var skipButton: NSButton!
    @IBOutlet weak var putOffButton: NSButton!

    @IBOutlet weak var workTimeText: NSTextField!
    @IBOutlet weak var restTimeText: NSTextField!
    @IBOutlet weak var putOffTimeText: NSTextField!
    
    @IBOutlet weak var work_time_unit: NSPopUpButton!
    @IBOutlet weak var rest_time_unit: NSPopUpButton!
    @IBOutlet weak var put_off_time_unit: NSPopUpButton!
    
    @IBOutlet weak var lastWorkTimeLabel: NSTextField!
    @IBOutlet weak var lastWorkTimeFixedLabel: NSTextField!
    @IBOutlet weak var lastWorkTimeProgress: NSProgressIndicator!

    @IBOutlet weak var lastRestTimeLabel: NSTextField!
    @IBOutlet weak var lastRestTimeFixedLabel: NSTextField!
    @IBOutlet weak var lastRestTimeProgress: NSProgressIndicator!

    let POPUP_SECONDS_INDEX : Int = 0
    let POPUP_MINUTES_INDEX : Int = 1
    let POPUP_HOURS_INDEX : Int = 2

    let SECOND_MULTIPLE : Double = 1
    let MINUTE_MULTIPLE : Double = 60
    let HOUR_MULTIPLE : Double = 60 * 60

    private var fakeWindows: [NSWindow] = [NSWindow]()
    
    private var tc : TimerControl = TimerControl()
    
    override init() {
        NSLog("AppDelegate::init()")
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        NSLog("AppDelegate::applicationDidFinishLaunching()")

        initSkipWindow()
        SetTimeIntervalFromUserDefault()
        tc.start()
        setStopButton()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func startButtonClick(sender: AnyObject) {
        NSLog("AppDelegate::startButtonClick()")
        SetTimeInterval()
        tc.start()
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
        tc.start()
        setStopButton()
    }
    
    @IBAction func putOffButtonClick(sender: AnyObject) {
    }
    
    @IBAction func breakNowClick(sender: AnyObject) {
        NSLog("AppDelegate::breakNowClicked()")
        
        tc.stop()
        tc.startToRest()
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
        NSLog("AppDelegate::SetTimeInterval()")
        NSLog("work_time_text=\(workTimeText.stringValue)")
        NSLog("rest_time_text=\(restTimeText.stringValue)")
        let work_time_interval : Double = Double(workTimeText.stringValue)!
        let rest_time_interval : Double = Double(restTimeText.stringValue)!
        
        if (work_time_interval > 0) {
            tc.work_time_interval = work_time_interval * Double(getTimesByIndexOfSelectedItem(work_time_unit.indexOfSelectedItem))
        }
        if (rest_time_interval > 0) {
            tc.rest_time_interval = rest_time_interval * Double(getTimesByIndexOfSelectedItem(rest_time_unit.indexOfSelectedItem))
        }
    }
    
    private func SetTimeIntervalFromUserDefault() {
        // work_time_interval is seconds
        let work_time_interval = NSUserDefaults.standardUserDefaults().doubleForKey("work_time_interval")
        let rest_time_interval = NSUserDefaults.standardUserDefaults().doubleForKey("rest_time_interval")
        let put_off_time_interval = NSUserDefaults.standardUserDefaults().doubleForKey("put_off_time_interval")

        if (work_time_interval > 0) {
            tc.work_time_interval = NSTimeInterval(work_time_interval)
        }
        initTimeFieldAndPopUp(tc.work_time_interval, field: workTimeText, popUp: work_time_unit)

        if (rest_time_interval > 0) {
            tc.rest_time_interval = NSTimeInterval(rest_time_interval)
        }
        initTimeFieldAndPopUp(tc.rest_time_interval, field: restTimeText, popUp: rest_time_unit)
        
        if (put_off_time_interval > 0) {
            tc.put_off_time_interval = NSTimeInterval(put_off_time_interval)
        }
        initTimeFieldAndPopUp(tc.put_off_time_interval, field: putOffTimeText, popUp: put_off_time_unit)
        
        NSLog(">>>> [config] work_time_interval=\(work_time_interval), rest_time_interval=\(rest_time_interval)")
    }
    
    func initSkipWindow() {
        let rect : NSRect = NSScreen.mainScreen()!.frame
        let windowXPos = (rect.width - skipWindow.frame.width) / 2
        let windowYPos = (rect.height - skipWindow.frame.height) / 2
        skipWindow.setFrameOrigin(NSPoint(x: windowXPos, y: windowYPos))
        skipWindow.titlebarAppearsTransparent = true
        skipWindow.titleVisibility = .Hidden
        skipWindow.styleMask = NSBorderlessWindowMask
        skipWindow.level = Int(CGWindowLevelForKey(.StatusWindowLevelKey)) + 1
        skipWindow.setIsVisible(false)
    }
    
    func rest() {
        skipWindow.setIsVisible(true)
        //constructFakeWindows()
    }
    
    func work() {
        skipWindow.setIsVisible(false)
        deconstructFakeWindows()
    }
    
    func constructFakeWindows() {
        for screen in NSScreen.screens()! {
            let window = NSWindow()
            window.collectionBehavior = NSWindowCollectionBehavior.CanJoinAllSpaces
            let frame = screen.frame
            window.level = Int(CGWindowLevelForKey(.StatusWindowLevelKey))
            window.titlebarAppearsTransparent  =   true
            window.titleVisibility             =   .Hidden
            window.styleMask = NSBorderlessWindowMask
            window.setFrame(frame, display: true)
            window.makeKeyAndOrderFront(window)
            window.backgroundColor = NSColor(deviceRed: 0.5, green: 0.5, blue: 0.5, alpha: 0.6)
            window.opaque = false
            window.toggleFullScreen(window)
            fakeWindows.append(window)
        }
    }
    
    func deconstructFakeWindows() {
        for window in self.fakeWindows {
            window.setIsVisible(false)
            window.orderOut(window)
            if let objIndex=self.fakeWindows.indexOf(window){
                self.fakeWindows.removeAtIndex(objIndex)
            }
        }
    }
    
    func getTimesByIndexOfSelectedItem(index : Int) -> Double {
        if (index == POPUP_SECONDS_INDEX) {
            return SECOND_MULTIPLE
        } else if (index == POPUP_MINUTES_INDEX) {
            return MINUTE_MULTIPLE
        } else if (index == POPUP_HOURS_INDEX) {
            return HOUR_MULTIPLE
        }
        return 0
    }
    
    func initTimeFieldAndPopUp(timeInterval : Double, field : NSTextField, popUp : NSPopUpButton) {
        var value = timeInterval
        if (timeInterval > HOUR_MULTIPLE) {
            value = Double(timeInterval) / Double(HOUR_MULTIPLE)
            popUp.selectItemAtIndex(POPUP_HOURS_INDEX)
        } else if (timeInterval > MINUTE_MULTIPLE) {
            value = Double(timeInterval) / Double(MINUTE_MULTIPLE)
            popUp.selectItemAtIndex(POPUP_MINUTES_INDEX)
        } else {
            value = Double(timeInterval) / Double(SECOND_MULTIPLE)
            popUp.selectItemAtIndex(POPUP_SECONDS_INDEX)
        }
        field.stringValue = String(value)
    }
}

