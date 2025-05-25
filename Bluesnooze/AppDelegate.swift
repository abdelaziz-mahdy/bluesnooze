//
//  AppDelegate.swift
//  Bluesnooze
//
//  Created by Oliver Peate on 07/04/2020.
//  Copyright © 2020 Oliver Peate. All rights reserved.
//

import Cocoa
import IOBluetooth
import LaunchAtLogin

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var launchAtLoginMenuItem: NSMenuItem!

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initStatusItem()
        setLaunchAtLoginState()
        setupNotificationHandlers()
        setupUserDefaultsObserver()
        setBluetooth(powerOn: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Remove observer when app terminates
        UserDefaults.standard.removeObserver(self, forKeyPath: "hideIcon")
    }

    // MARK: Click handlers

    @IBAction func launchAtLoginClicked(_ sender: NSMenuItem) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        setLaunchAtLoginState()
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    // MARK: Notification handlers

    func setupNotificationHandlers() {
        [
            NSWorkspace.willSleepNotification: #selector(onPowerDown(note:)),
            NSWorkspace.willPowerOffNotification: #selector(onPowerDown(note:)),
            NSWorkspace.didWakeNotification: #selector(onPowerUp(note:))
        ].forEach { notification, sel in
            NSWorkspace.shared.notificationCenter.addObserver(self, selector: sel, name: notification, object: nil)
        }
    }

    @objc func onPowerDown(note: NSNotification) {
        setBluetooth(powerOn: false)
    }

    @objc func onPowerUp(note: NSNotification) {
        setBluetooth(powerOn: true)
    }

    private func setBluetooth(powerOn: Bool) {
        IOBluetoothPreferenceSetControllerPowerState(powerOn ? 1 : 0)
    }

    // MARK: UI state

    private func initStatusItem() {
        let shouldHideIcon = UserDefaults.standard.bool(forKey: "hideIcon")
        
        print("DEBUG: hideIcon setting = \(shouldHideIcon)")

        if shouldHideIcon {
            // Hide the status item from the menu bar
            statusItem.isVisible = false
            print("DEBUG: Status item hidden")
        } else {
            // Show the status item in the menu bar
            statusItem.isVisible = true
            print("DEBUG: Status item visible")

            if let icon = NSImage(named: "bluesnooze") {
                icon.isTemplate = true
                statusItem.button?.image = icon
                print("DEBUG: Icon set successfully")
            } else {
                statusItem.button?.title = "Bluesnooze"
                print("DEBUG: Using text title instead of icon")
            }
            statusItem.menu = statusMenu
        }
        
        // Always set the menu so it's available even when hidden
        // (this won't show the icon, but keeps the menu accessible programmatically)
        statusItem.menu = statusMenu
    }

    private func setLaunchAtLoginState() {
        let state = LaunchAtLogin.isEnabled ? NSControl.StateValue.on : NSControl.StateValue.off
        launchAtLoginMenuItem.state = state
    }

    private func setupUserDefaultsObserver() {
        UserDefaults.standard.addObserver(
            self,
            forKeyPath: "hideIcon",
            options: .new,
            context: nil
        )
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "hideIcon" {
            print("DEBUG: hideIcon setting changed, updating status item")
            DispatchQueue.main.async {
                self.initStatusItem()
            }
        }
    }
}
