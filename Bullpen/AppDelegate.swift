//
//  AppDelegate.swift
//  Bullpen
//
//  Created by Joshua Kraft on 11/6/21.
//  Copyright © 2021 Joshua Kraft. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, StompDelegate {

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
        
        // Add the XML Consumer
        
        stompClient().delegate = self
        stompClient().add(bullpenConsumer, forDestination: TempQueueName, withSelector: nil, prefetchSize: 1000)
        
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        stompClient().remove(bullpenConsumer)
        stompClient().disconnect()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    
    // MARK: - Delegate methods
    
    @objc func receivedNonExistantDestination(_ aFrame: StompFrame!) {
        print("receivedNonExistantDestination")
    }
    
    @objc func receivedError(_ aFrame: StompFrame!) {
        print("receivedError")
    }
    
    @objc func receivedReceipt(_ aFrame: StompFrame!) {
        print("receivedReceipt")
    }
    
    @objc func missingHeartbeat(_ inBody: Bool) {
        print("missingHeartbeat")
    }
    
    @objc func receivedDisconnect(_ aFrame: StompFrame!) {
        print("receivedDisconnect")
    }
    
    @objc func networkException(_ e: NSException!) -> Bool {
        print("networkException")
        return true
    }
    

}

