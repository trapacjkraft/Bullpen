//
//  ViewController.swift
//  Bullpen
//
//  Created by Joshua Kraft on 11/6/21.
//  Copyright © 2021 Joshua Kraft. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // Worker class for creating XML data
    
    let letterGenerator = PitchLetterGenerator()
    
    // Create outlets for the various parts of the GUI
    
    @IBOutlet var vesselCodeTextField: NSTextField!
    @IBOutlet var vesselNameTextField: NSTextField!

    @IBOutlet var craneNumberPopUp: NSPopUpButton!
    let craneNumbers = ["101", "102", "103", "104", "105", "106", "107", "108", "109", "110"] // Used to populate the values of the crane number drop-down
    
    @IBOutlet var sideToBerthPopUp: NSPopUpButton!
    let sides = ["Port", "Starboard"]
    
    @IBOutlet var inboundVoyageTextField: NSTextField!
    @IBOutlet var outboundVoyageTextField: NSTextField!
    
    @IBOutlet var liftStartDatePicker: NSDatePicker!
    @IBOutlet var liftEndDatePicker: NSDatePicker!
    
    @IBOutlet var pitchInTextView: NSTextView!
    @IBOutlet var pitchOutTextView: NSTextView!
    
    @IBOutlet var cycleCheckBox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Populate the crane number drop-down
        // Select 103 as the default
        craneNumberPopUp.removeAllItems()
        craneNumberPopUp.addItems(withTitles: craneNumbers)
        craneNumberPopUp.selectItem(withTitle: "103")
        
        // Populate the side-to drop-down
        // Select Port as the default
        
        sideToBerthPopUp.removeAllItems()
        sideToBerthPopUp.addItems(withTitles: sides)
        sideToBerthPopUp.selectItem(withTitle: "Port")
        
        // Set the locales of the date pickers to Zulu for zulu-formatted time
        // Retain the autoupdating current time zone of the user
        // Set the value to the time of launch
        
        liftStartDatePicker.locale = .init(identifier: "zu")
        liftStartDatePicker.timeZone = .autoupdatingCurrent
        liftStartDatePicker.dateValue = Date()
        

        liftEndDatePicker.locale = .init(identifier: "zu")
        liftEndDatePicker.timeZone = .autoupdatingCurrent
        liftEndDatePicker.dateValue = Date()
        
        // Add a notification observer for when the STOMPKit is done processing
        
        NotificationCenter.default.addObserver(letterGenerator, selector: #selector(letterGenerator.nmoWasReceived), name: .nmoReceived, object: nil)
        NotificationCenter.default.addObserver(letterGenerator, selector: #selector(letterGenerator.generateXMLData), name: .allEDARequestsReceived, object: nil)
        
    }
    
    @IBAction func generatePitchLetter(_ sender: Any) {
        
        // Create an array of container names by separating the text field on newlines. If this fails, create an empty array.
        // Loop through the array and find any empty lines that may have arrived from copy-pasting or extra lines in lists, and remove empty entries.
                
        var pitchInContainerNames = pitchInTextView.textContainer?.textView?.string.components(separatedBy: "\n") ?? []
        
        // Depending on where the list is copied, sometimes \r escape characters are included. Strip these.
        
        for (index, container) in pitchInContainerNames.enumerated() {
            if container.contains("\r") {
                pitchInContainerNames[index] = container.replacingOccurrences(of: "\r", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        var emptyIndex = [Int]()
        
        for (i, container) in pitchInContainerNames.enumerated() {
            if container.isEmpty {
                emptyIndex.append(i)
            }
        }
        
        for index in emptyIndex.reversed() {
            pitchInContainerNames.remove(at: index)
        }
        
        CommonVariables.sharedInstance.pitchInCount = pitchInContainerNames.count
        
        // Reset the index tracker and repeat the above process for the pitch out containers.
        
        emptyIndex.removeAll()
        
        var pitchOutContainerNames = pitchOutTextView.textContainer?.textView?.string.components(separatedBy: "\n") ?? []
        
        // Depending on where the list is copied, sometimes \r escape characters are included. Strip these.
        
        for (index, container) in pitchOutContainerNames.enumerated() {
            if container.contains("\r") {
                pitchOutContainerNames[index] = container.replacingOccurrences(of: "\r", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        
        for (i, container) in pitchOutContainerNames.enumerated() {
            if container.isEmpty {
                emptyIndex.append(i)
            }
        }
        
        for index in emptyIndex.reversed() {
            pitchOutContainerNames.remove(at: index)
        }
        
        CommonVariables.sharedInstance.pitchOutCount = pitchOutContainerNames.count

        // Use a date formatter to format the strings for LiftStart and LiftEnd
        // Use the UTC time zone to automatically convert from the user's time
        
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
        df.timeZone = TimeZone(identifier: "UTC")
        
        // Check if the cycling checkbox is enabled
        
        var isCycling = Bool()
        
        if cycleCheckBox.state == .on {
            isCycling = true
        } else {
            isCycling = false
        }
        
        // Pass the letter options and container lists to the XML generator.
        
        letterGenerator.getLetterOptions(code: vesselCodeTextField.stringValue,
                                         name: vesselNameTextField.stringValue,
                                         iVoyage: inboundVoyageTextField.stringValue,
                                         oVoyage: outboundVoyageTextField.stringValue,
                                         sideto: sideToBerthPopUp.selectedItem?.title ?? "Port", // Use Port as the default side-to
                                         crane: craneNumberPopUp.selectedItem?.title ?? "103", // Use 103 as a default number
                                         start: df.string(from: liftStartDatePicker.dateValue),
                                         end: df.string(from: liftEndDatePicker.dateValue),
                                         pitchins: pitchInContainerNames,
                                         pitchouts: pitchOutContainerNames,
                                         cycling: isCycling)
        
        
        letterGenerator.getEDAContainers()
//        letterGenerator.generateXMLData()
        
    }
    
}

