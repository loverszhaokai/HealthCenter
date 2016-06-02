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

    @IBOutlet weak var preferenceWindow: NSWindow!
    @IBOutlet weak var skipWindow: NSWindow!

    @IBOutlet weak var skipButton: NSButton!
    @IBOutlet weak var putOffButton: NSButton!

    @IBOutlet weak var workTimeText: NSTextField!
    @IBOutlet weak var restTimeText: NSTextField!
    @IBOutlet weak var putOffTimeText: NSTextField!
    
    @IBOutlet weak var work_time_unit: NSPopUpButton!
    @IBOutlet weak var rest_time_unit: NSPopUpButton!
    @IBOutlet weak var put_off_time_unit: NSPopUpButton!

    @IBOutlet weak var lastRestTimeLabel: NSTextField!
    @IBOutlet weak var lastRestTimeFixedLabel: NSTextField!
    @IBOutlet weak var lastRestTimeProgress: NSProgressIndicator!

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var lastTimeMenuLabel: NSMenuItem!
    
    let statusBar = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let POPUP_SECONDS_INDEX : Int = 0
    let POPUP_MINUTES_INDEX : Int = 1
    let POPUP_HOURS_INDEX : Int = 2

    let SECOND_MULTIPLE : Double = 1
    let MINUTE_MULTIPLE : Double = 60
    let HOUR_MULTIPLE : Double = 60 * 60
    
    let WORK_TIME_INTERVAL = "work_time_interval"
    let REST_TIME_INTERVAL = "rest_time_interval"
    let PUT_OFF_TIME_INTERVAL = "put_off_time_interval"
    
    let WORK_TIME_INTERVAL_SELECTED_INDEX = "work_time_interval_selected_index"
    let REST_TIME_INTERVAL_SELECTED_INDEX = "rest_time_interval_selected_index"
    let PUT_OFF_TIME_INTERVAL_SELECTED_INDEX = "put_off_time_interval_selected_index"

    private var fakeWindows: [NSWindow] = [NSWindow]()
    
    private var tc : TimerControl = TimerControl()
    
    override init() {
        NSLog("AppDelegate::init()")
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        NSLog("AppDelegate::applicationDidFinishLaunching()")

        initMenu()
        initPreferenceWindow()
        initSkipWindow()
        SetTimeIntervalFromUserDefault()
        tc.workStart()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func workTimeTextChanged(sender: AnyObject) {
        NSLog("AppDelegate::workTimeTextChanged()")
        SetTimeInterval()
    }
    
    @IBAction func restTimeTextChanged(sender: AnyObject) {
        NSLog("AppDelegate::restTimeTextChanged()")
        SetTimeInterval()
    }
    
    @IBAction func skipButtonClick(sender: AnyObject) {
        NSLog("AppDelegate::skipButtonClick()")
        tc.workStart()
    }
    
    @IBAction func putOffButtonClick(sender: AnyObject) {
        SetPutOffTimeInterval()
        tc.putOffStart()
    }
    
    @IBAction func restNowClick(sender: AnyObject) {
        tc.stop()
        tc.startToRest()
    }
    
    @IBAction func preferenceClick(sender: AnyObject) {
        preferenceWindow.setIsVisible(true)
    }
    
    @IBAction func quitClick(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }

    func SetTimeInterval() {
        NSLog("AppDelegate::SetTimeInterval()")
        NSLog("work_time_text=\(workTimeText.stringValue)")
        NSLog("rest_time_text=\(restTimeText.stringValue)")
        let work_time_interval : Double = Double(workTimeText.stringValue)!
        let rest_time_interval : Double = Double(restTimeText.stringValue)!
        
        if (work_time_interval > 0) {
            tc.work_time_interval = work_time_interval * Double(getTimesByIndexOfSelectedItem(work_time_unit.indexOfSelectedItem))
            NSUserDefaults.standardUserDefaults().setObject(work_time_interval, forKey: WORK_TIME_INTERVAL)
            NSUserDefaults.standardUserDefaults().setObject(work_time_unit.indexOfSelectedItem
                + 1, forKey: WORK_TIME_INTERVAL_SELECTED_INDEX)
        }
        if (rest_time_interval > 0) {
            tc.rest_time_interval = rest_time_interval * Double(getTimesByIndexOfSelectedItem(rest_time_unit.indexOfSelectedItem))
            NSUserDefaults.standardUserDefaults().setObject(rest_time_interval, forKey: REST_TIME_INTERVAL)
            NSUserDefaults.standardUserDefaults().setObject(rest_time_unit.indexOfSelectedItem + 1, forKey: REST_TIME_INTERVAL_SELECTED_INDEX)
        }
    }
    
    func SetPutOffTimeInterval() {
        let put_off_time_interval : Double = Double(putOffTimeText.stringValue)!
        
        if (put_off_time_interval > 0) {
            tc.put_off_time_interval = put_off_time_interval * Double(getTimesByIndexOfSelectedItem(put_off_time_unit.indexOfSelectedItem))
            NSUserDefaults.standardUserDefaults().setObject(put_off_time_interval, forKey: PUT_OFF_TIME_INTERVAL)
            NSUserDefaults.standardUserDefaults().setObject(put_off_time_unit.indexOfSelectedItem + 1, forKey: PUT_OFF_TIME_INTERVAL_SELECTED_INDEX)
        }
    }
    
    private func SetTimeIntervalFromUserDefault() {
        // work_time_interval is seconds
        let work_time_interval = NSUserDefaults.standardUserDefaults().doubleForKey(WORK_TIME_INTERVAL)
        let rest_time_interval = NSUserDefaults.standardUserDefaults().doubleForKey(REST_TIME_INTERVAL)
        let put_off_time_interval = NSUserDefaults.standardUserDefaults().doubleForKey(PUT_OFF_TIME_INTERVAL)
        
        let work_time_interval_selected_index = NSUserDefaults.standardUserDefaults().integerForKey(WORK_TIME_INTERVAL_SELECTED_INDEX)
        let rest_time_interval_selected_index = NSUserDefaults.standardUserDefaults().integerForKey(REST_TIME_INTERVAL_SELECTED_INDEX)
        let put_off_time_interval_selected_index = NSUserDefaults.standardUserDefaults().integerForKey(PUT_OFF_TIME_INTERVAL_SELECTED_INDEX)

        if (work_time_interval > 0 && work_time_interval_selected_index > 0) {
            tc.work_time_interval = work_time_interval * Double(getTimesByIndexOfSelectedItem(work_time_interval_selected_index - 1))
            workTimeText.stringValue = String(work_time_interval)
            work_time_unit.selectItemAtIndex(work_time_interval_selected_index - 1)
        } else {
            initTimeFieldAndPopUp(tc.work_time_interval, field: workTimeText, popUp: work_time_unit)
        }

        if (rest_time_interval > 0 && rest_time_interval_selected_index > 0) {
            tc.rest_time_interval = rest_time_interval * Double(getTimesByIndexOfSelectedItem(rest_time_interval_selected_index - 1))
            restTimeText.stringValue = String(rest_time_interval)
            rest_time_unit.selectItemAtIndex(rest_time_interval_selected_index - 1)
        } else {
            initTimeFieldAndPopUp(tc.rest_time_interval, field: restTimeText, popUp: rest_time_unit)
        }
        
        if (put_off_time_interval > 0 && put_off_time_interval_selected_index > 0) {
            tc.put_off_time_interval = put_off_time_interval * Double(getTimesByIndexOfSelectedItem(put_off_time_interval_selected_index - 1))
            putOffTimeText.stringValue = String(put_off_time_interval)
            put_off_time_unit.selectItemAtIndex(put_off_time_interval_selected_index - 1)
        } else {
            initTimeFieldAndPopUp(tc.put_off_time_interval, field: putOffTimeText, popUp: put_off_time_unit)
        }
        NSLog(">>>> [config] work_time_interval=\(work_time_interval), rest_time_interval=\(rest_time_interval)")
    }
    
    func initMenu() {
        let icon = NSImage(named: "ball6")
        icon?.template = true
        statusBar.image = icon
        statusBar.menu = menu
    }
    
    func initPreferenceWindow() {
        setWindowToCenter(preferenceWindow)
        preferenceWindow.setIsVisible(false)
    }
    
    func initSkipWindow() {
        setWindowToCenter(skipWindow)
        skipWindow.titlebarAppearsTransparent = true
        skipWindow.titleVisibility = .Hidden
        skipWindow.styleMask &= ~(NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask)
        skipWindow.level = Int(CGWindowLevelForKey(.StatusWindowLevelKey)) + 100
        skipWindow.setIsVisible(false)
    }
    
    func rest() {
        skipWindow.setIsVisible(true)
        constructFakeWindows()
    }
    
    func work() {
        preferenceWindow.makeKeyWindow()
        skipWindow.setIsVisible(false)
        deconstructFakeWindows()
    }
    
    func constructFakeWindows() {
        for screen in NSScreen.screens()! {
            let win = NSWindow()
            win.collectionBehavior = NSWindowCollectionBehavior.CanJoinAllSpaces
            let frame = screen.frame
            win.level = Int(CGWindowLevelForKey(.StatusWindowLevelKey))
            win.titlebarAppearsTransparent  =   true
            win.titleVisibility             =   .Hidden
            win.styleMask = NSBorderlessWindowMask
            win.setFrame(frame, display: true)
            win.makeKeyAndOrderFront(win)
            win.backgroundColor = NSColor(deviceRed: 0.5, green: 0.5, blue: 0.5, alpha: 0.6)
            win.opaque = false
            win.toggleFullScreen(win)
            fakeWindows.append(win)
        }
    }
    
    func deconstructFakeWindows() {
        for win in self.fakeWindows {
            win.setIsVisible(false)
            win.orderOut(win)
            if let objIndex=self.fakeWindows.indexOf(win){
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
    
    func setWindowToCenter(win : NSWindow) {
        let rect : NSRect = NSScreen.mainScreen()!.frame
        var winXPos = (rect.width - win.frame.width) / 2

        if (winXPos + win.frame.width + 50 >= rect.width) {
            winXPos = rect.width - win.frame.width - 50
        }
        
        var winYPos = rect.height / 2
        if (winYPos + win.frame.height + 50 >= rect.height) {
            winYPos = rect.height - win.frame.height - 50
        }
        
        win.setFrameOrigin(NSPoint(x: winXPos, y: winYPos))
    }
}

