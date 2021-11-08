//
//  AppDelegate.swift
//  Bullpen
//
//  Created by Joshua Kraft on 11/6/21.
//  Copyright © 2021 Joshua Kraft. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // Shared path for the export directory
    static let pitchLetterDirectory: String = NSHomeDirectory() + "/Documents/Pitch Letters/"

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // Create the export directory, if it doesn't exist.
        
        if !FileManager.default.fileExists(atPath: AppDelegate.pitchLetterDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: AppDelegate.pitchLetterDirectory, withIntermediateDirectories: true, attributes: .none)
            } catch {
                NSAlert(error: error).runModal()
            }
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        // Quit the application if the window is closed.
        
        return true
    }


}

