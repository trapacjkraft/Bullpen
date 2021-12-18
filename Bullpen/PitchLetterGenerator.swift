//
//  PitchLetterGenerator.swift
//  Bullpen
//
//  Created by Joshua Kraft on 11/7/21.
//  Copyright © 2021 Joshua Kraft. All rights reserved.
//

import Cocoa

class PitchLetterGenerator: NSObject {
    
    // Variables to store the letter options and containers
    
    var vesselCode = ""
    var vesselName = ""
    var inboundVoyage = ""
    var outboundVoyage = ""
    var berthingSide = ""
    var craneIdentity = ""
    var liftStart = ""
    var liftEnd = ""
    
    var isCycling = Bool()
    
    var pitchInContainerNames = [String]()
    var pitchOutContainerNames = [String]()
    
    var nmoReceived = false
    
    var df = DateFormatter()
    
    // Populate the variables with data from ViewController
    
    func getLetterOptions(code: String, name: String, iVoyage: String, oVoyage: String, sideto: String, crane: String, start: String, end: String, pitchins: [String], pitchouts: [String], cycling: Bool) {
        vesselCode = code
        vesselName = name
        inboundVoyage = iVoyage
        outboundVoyage = oVoyage
        berthingSide = sideto
        craneIdentity = crane
        liftStart = start
        liftEnd = end
        
        pitchInContainerNames = pitchins
        pitchOutContainerNames = pitchouts
        
        isCycling = cycling
        
    }
    
    func getEDAContainers() {
        
        var edaContainerRequestNames = [String]()
        
        if !pitchInContainerNames.isEmpty {
            edaContainerRequestNames = edaContainerRequestNames + pitchInContainerNames
        }
        
        if !pitchOutContainerNames.isEmpty {
            edaContainerRequestNames = edaContainerRequestNames + pitchOutContainerNames
        }
        
        requestEDAContainers(names: edaContainerRequestNames)
    }
    
    @objc func nmoWasReceived() {
        nmoReceived = true
    }
    
    // Write the XML data
    
    @objc func generateXMLData() {
        
        guard !nmoReceived else {
            let alert = NSAlert()
            alert.messageText = "Invalid container(s)!"
            let info = CommonVariables.sharedInstance.nmos.joined(separator: ", ")
            alert.informativeText = "The following containers in your lists are invalid: \n \(info).\n\nPlease check the container IDs and try again."
            alert.runModal()
            CommonVariables.sharedInstance.edaContainers.removeAll()
            CommonVariables.sharedInstance.nmos.removeAll()
            nmoReceived = false
            return
        }
        
        var pitchInContainers = [EDAContainer]()
        var pitchOutContainers = [EDAContainer]()
        
        // Filter the edaContainers by list
        pitchInContainers = CommonVariables.sharedInstance.edaContainers.filter( { self.pitchInContainerNames.contains($0.name) } )
        pitchOutContainers = CommonVariables.sharedInstance.edaContainers.filter( { self.pitchOutContainerNames.contains($0.name) } )
        
        // Create the root element

        let rootElement = XMLElement(name: "QCWorkLetter")
        
        
        // Add the letter options as child elements
        
        rootElement.addChild(XMLElement(name: "VesselCode", stringValue: vesselCode))
        rootElement.addChild(XMLElement(name: "VesselName", stringValue: vesselName))
        rootElement.addChild(XMLElement(name: "InboundVoyage", stringValue: inboundVoyage))
        rootElement.addChild(XMLElement(name: "OutboundVoyage", stringValue: outboundVoyage))
        rootElement.addChild(XMLElement(name: "BerthingSide", stringValue: berthingSide))
        rootElement.addChild(XMLElement(name: "CraneIdentity", stringValue: craneIdentity))
        rootElement.addChild(XMLElement(name: "LiftStart", stringValue: liftStart))
        rootElement.addChild(XMLElement(name: "LiftEnd", stringValue: liftEnd))

        
        // Create the CraneSequence elements for pitch-ins, pitch-outs, or cycling
        
        let pitchInCraneSequence = XMLElement(name: "CraneSequence")
        pitchInCraneSequence.addChild(XMLElement(name: "Number", stringValue: "9901")) // Default crane sequence values of 9901, 99 On deck for pitch-in
        pitchInCraneSequence.addChild(XMLElement(name: "Bay", stringValue: "99"))
        pitchInCraneSequence.addChild(XMLElement(name: "Deck", stringValue: "O"))
        
        let pitchOutCraneSequence = XMLElement(name: "CraneSequence")
        pitchOutCraneSequence.addChild(XMLElement(name: "Number", stringValue: "9801")) // Default crane sequence values of 9801, 98 On deck for pitch-out
        pitchOutCraneSequence.addChild(XMLElement(name: "Bay", stringValue: "98"))
        pitchOutCraneSequence.addChild(XMLElement(name: "Deck", stringValue: "O"))

        let cycleCraneSequence = XMLElement(name: "CraneSequence")
        cycleCraneSequence.addChild(XMLElement(name: "Number", stringValue: "9701")) // Default crane sequence values of 9701, 97 On deck for cycling
        cycleCraneSequence.addChild(XMLElement(name: "Bay", stringValue: "97"))
        cycleCraneSequence.addChild(XMLElement(name: "Deck", stringValue: "O"))


        // Create the SequenceSummary Element for pitch-ins and pitch-out
        
        let pitchInSequenceSummary = XMLElement(name: "SequenceSummary")
        pitchInSequenceSummary.addChild(XMLElement(name: "Direction", stringValue: "Discharge"))
        pitchInSequenceSummary.addChild(XMLElement(name: "Count", stringValue: String(pitchInContainerNames.count)))
        pitchInSequenceSummary.addChild(XMLElement(name: "Length", stringValue: "40")) // Use default value of 40 for now -- maybe query EDA later?
        
        let pitchOutSequenceSummary = XMLElement(name: "SequenceSummary")
        pitchOutSequenceSummary.addChild(XMLElement(name: "Direction", stringValue: "Load"))
        pitchOutSequenceSummary.addChild(XMLElement(name: "Count", stringValue: String(pitchOutContainerNames.count)))
        pitchOutSequenceSummary.addChild(XMLElement(name: "Length", stringValue: "40")) // Use default value of 40 for now -- maybe query EDA later?
        
        // Set boolean flags to determine whether lists are empty (and so if to add the relevant sequence summary)
        
        let pitchingIn: Bool = {
            if pitchInSequenceSummary.elements(forName: "Count").first!.stringValue == "0" {
                return false
            } else { return true }
        }()
        
        let pitchingOut: Bool = {
            if pitchOutSequenceSummary.elements(forName: "Count").first!.stringValue == "0" {
                return false
            } else { return true }
        }()

        
        // Add the sequence summaries to the appropriate crane sequences
        if !isCycling {
            pitchInCraneSequence.addChild(pitchInSequenceSummary)
            pitchOutCraneSequence.addChild(pitchOutSequenceSummary)
        } else {
            cycleCraneSequence.addChild(pitchInSequenceSummary)
            cycleCraneSequence.addChild(pitchOutSequenceSummary)
        }
                
                
        // Determine whether or not the letter should be generated as a cycle
        
        if !isCycling {
            
            // If not cycling, append the text to the pitch-in crane sequence.
            // Then append a container element for each container on the pitch-in list.
            // Then append the pitch in crane sequence to the root element.
            
            // Then repeat the process for the pitch outs.
                        
            let pitchInText = XMLElement(name: "Text", stringValue: "Pitch-In Letter for \(pitchInContainerNames.count) containers.")
            pitchInCraneSequence.addChild(pitchInText)
            
            var pitchInStow = 990000 // Set a variable for the stow position. Increment by 1.
            
            
            for container in pitchInContainers {
                
                // For each container, create a planned lift element.
                // Within PlannedLift, create a discharge element, and populate the discharge element with the container info.
                // Add the discharge element to planned lift, and add the planned lift to the crane sequence.
                
                let plannedLift = XMLElement(name: "PlannedLift")
                let dischargeElement = XMLElement(name: "DischargeContainerToAutomation")
                dischargeElement.addChild(XMLElement(name: "ContainerName", stringValue: container.name)) // Use the container name from the loop
                dischargeElement.addChild(XMLElement(name: "StowPosition", stringValue: String(pitchInStow))) // Cast the stow position to String
                dischargeElement.addChild(XMLElement(name: "DoorDirection", stringValue: "North")) // Use north as default for now
                dischargeElement.addChild(XMLElement(name: "IsoCode", stringValue: container.crossbowISOCode))
                pitchInStow += 1 // increment the pitch-in stow position
                plannedLift.addChild(dischargeElement)  // Add the discharge element to PlannedLift
                pitchInCraneSequence.addChild(plannedLift) // Add PlannedLift to the CraneSequence
                
            }

            
            if pitchingIn {
                rootElement.addChild(pitchInCraneSequence) // Add the CraneSequence to the QCWorkLetter
            }
            
            // Add the text to the pitch out crane sequence
            
            let pitchOutText = XMLElement(name: "Text", stringValue: "Pitch-Out Letter for \(pitchOutContainerNames.count) containers.")
            pitchOutCraneSequence.addChild(pitchOutText)
            
            var pitchOutStow = 980000
            
            for container in pitchOutContainers {
                // For each container, create a planned lift element.
                // Within PlannedLift, create a load element, and populate the load element with the container info.
                // Add the load element to planned lift, and add the planned lift to the crane sequence.
                
                let plannedLift = XMLElement(name: "PlannedLift")
                let loadElement = XMLElement(name: "LoadContainerFromAutomation")
                loadElement.addChild(XMLElement(name: "ContainerName", stringValue: container.name)) // Use the container name from the loop
                loadElement.addChild(XMLElement(name: "StowPosition", stringValue: String(pitchOutStow))) // Cast the stow position to String
                loadElement.addChild(XMLElement(name: "DoorDirection", stringValue: "North")) // Use north as default for now
                loadElement.addChild(XMLElement(name: "IsoCode", stringValue: container.crossbowISOCode))
                pitchOutStow += 1 // increment the pitch-in stow position
                plannedLift.addChild(loadElement)
                pitchOutCraneSequence.addChild(plannedLift)

            }
            
            
            if pitchingOut {
                rootElement.addChild(pitchOutCraneSequence) // Add the CraneSequence to the QCWorkLetter
            }
            
            writeXML(root: rootElement)

        } else {
            
            // If cycling, find the longer list and set the appropriate flags
            // Or set the flag for equal length
            
            var pitchInContainersLonger = false
            var pitchOutContainersLonger = false
            var listsAreSameLength = false
            
            if pitchInContainerNames.count > pitchOutContainerNames.count {
                pitchInContainersLonger = true
            } else if pitchInContainerNames.count < pitchOutContainerNames.count {
                pitchOutContainersLonger = true
            } else {
                listsAreSameLength = true
            }
            
            // Append the text sequence
            
            let cycleText = XMLElement(name: "Text", stringValue: "Cycle Pitch Letter for \(pitchInContainerNames.count) pitch-ins and \(pitchOutContainerNames.count) pitch-outs.")
            cycleCraneSequence.addChild(cycleText)

            // Create the stow position
            
            var cycleStow = 970000

            if listsAreSameLength {
                
                // If lists are the same length, process each list in parallell
                // Create a discharge and load lift and add them in that order to the cycle crane sequence
                
                for (i, _) in pitchInContainers.enumerated() {
                    
                    let plannedDischargeLift = XMLElement(name: "PlannedLift")
                    let dischargeElement = XMLElement(name: "DischargeContainerToAutomation")
                    dischargeElement.addChild(XMLElement(name: "ContainerName", stringValue: pitchInContainers[i].name)) // Use the container name from the loop
                    dischargeElement.addChild(XMLElement(name: "StowPosition", stringValue: String(cycleStow))) // Cast the stow position to String
                    dischargeElement.addChild(XMLElement(name: "DoorDirection", stringValue: "North")) // Use north as default for now
                    dischargeElement.addChild(XMLElement(name: "IsoCode", stringValue: pitchInContainers[i].crossbowISOCode))
                    cycleStow += 1 // increment the pitch-in stow position
                    plannedDischargeLift.addChild(dischargeElement)  // Add the discharge element to PlannedLift
                    cycleCraneSequence.addChild(plannedDischargeLift) // Add PlannedLift to the CraneSequence
                    
                    let plannedLoadLift = XMLElement(name: "PlannedLift")
                    let loadElement = XMLElement(name: "LoadContainerFromAutomation")
                    loadElement.addChild(XMLElement(name: "ContainerName", stringValue: pitchOutContainers[i].name)) // Use the container name from the loop
                    loadElement.addChild(XMLElement(name: "StowPosition", stringValue: String(cycleStow))) // Cast the stow position to String
                    loadElement.addChild(XMLElement(name: "DoorDirection", stringValue: "North")) // Use north as default for now
                    loadElement.addChild(XMLElement(name: "IsoCode", stringValue: pitchOutContainers[i].crossbowISOCode))
                    cycleStow += 1 // increment the pitch-in stow position
                    plannedLoadLift.addChild(loadElement)  // Add the discharge element to PlannedLift
                    cycleCraneSequence.addChild(plannedLoadLift) // Add PlannedLift to the CraneSequence

                }
                
                // Add the lifts to the crane sequence
                
                rootElement.addChild(cycleCraneSequence)
                
                writeXML(root: rootElement)

                
            } else {
                
                // Use the longer of the two lists to ensure that .enumerated() returns an index for the last possible container
                // Check if the index exists inside of the shorter list before creating the element
                
                // This ensures TVS-style cycling where an unbalanced amount of discharge/load results in whichever of the two
                // work types is heavier just follow the cycled containers sequentially.
                
                if pitchInContainersLonger {
                    
                    for (i, _) in pitchInContainers.enumerated() {
                        
                        let plannedDischargeLift = XMLElement(name: "PlannedLift")
                        let dischargeElement = XMLElement(name: "DischargeContainerToAutomation")
                        dischargeElement.addChild(XMLElement(name: "ContainerName", stringValue: pitchInContainers[i].name)) // Use the container name from the loop
                        dischargeElement.addChild(XMLElement(name: "StowPosition", stringValue: String(cycleStow))) // Cast the stow position to String
                        dischargeElement.addChild(XMLElement(name: "DoorDirection", stringValue: "North")) // Use north as default for now
                        dischargeElement.addChild(XMLElement(name: "IsoCode", stringValue: pitchInContainers[i].crossbowISOCode))
                        cycleStow += 1 // increment the pitch-in stow position
                        plannedDischargeLift.addChild(dischargeElement)  // Add the discharge element to PlannedLift
                        cycleCraneSequence.addChild(plannedDischargeLift) // Add PlannedLift to the CraneSequence

                        if i <= pitchOutContainers.count - 1 {
                            let plannedLoadLift = XMLElement(name: "PlannedLift")
                            let loadElement = XMLElement(name: "LoadContainerFromAutomation")
                            loadElement.addChild(XMLElement(name: "ContainerName", stringValue: pitchOutContainers[i].name)) // Use the container name from the loop
                            loadElement.addChild(XMLElement(name: "StowPosition", stringValue: String(cycleStow))) // Cast the stow position to String
                            loadElement.addChild(XMLElement(name: "DoorDirection", stringValue: "North")) // Use north as default for now
                            loadElement.addChild(XMLElement(name: "IsoCode", stringValue: pitchOutContainers[i].crossbowISOCode))
                            cycleStow += 1 // increment the pitch-in stow position
                            plannedLoadLift.addChild(loadElement)  // Add the discharge element to PlannedLift
                            cycleCraneSequence.addChild(plannedLoadLift) // Add PlannedLift to the CraneSequence
                        }
                        
                    }
                    
                } else if pitchOutContainersLonger {
                    
                    for (i, _) in pitchOutContainers.enumerated() {
                        
                        if i <= pitchInContainers.count - 1 {
                            let plannedDischargeLift = XMLElement(name: "PlannedLift")
                            let dischargeElement = XMLElement(name: "DischargeContainerToAutomation")
                            dischargeElement.addChild(XMLElement(name: "ContainerName", stringValue: pitchInContainers[i].name)) // Use the container name from the loop
                            dischargeElement.addChild(XMLElement(name: "StowPosition", stringValue: String(cycleStow))) // Cast the stow position to String
                            dischargeElement.addChild(XMLElement(name: "DoorDirection", stringValue: "North")) // Use north as default for now
                            dischargeElement.addChild(XMLElement(name: "IsoCode", stringValue: pitchInContainers[i].crossbowISOCode))
                            cycleStow += 1 // increment the pitch-in stow position
                            plannedDischargeLift.addChild(dischargeElement)  // Add the discharge element to PlannedLift
                            cycleCraneSequence.addChild(plannedDischargeLift) // Add PlannedLift to the CraneSequence
                        }

                        let plannedLoadLift = XMLElement(name: "PlannedLift")
                        let loadElement = XMLElement(name: "LoadContainerFromAutomation")
                        loadElement.addChild(XMLElement(name: "ContainerName", stringValue: pitchOutContainers[i].name)) // Use the container name from the loop
                        loadElement.addChild(XMLElement(name: "StowPosition", stringValue: String(cycleStow))) // Cast the stow position to String
                        loadElement.addChild(XMLElement(name: "DoorDirection", stringValue: "North")) // Use north as default for now
                        loadElement.addChild(XMLElement(name: "IsoCode", stringValue: pitchOutContainers[i].crossbowISOCode)) // Use 45G1 as default for now -- maybe query EDA later?
                        cycleStow += 1 // increment the pitch-in stow position
                        plannedLoadLift.addChild(loadElement)  // Add the discharge element to PlannedLift
                        cycleCraneSequence.addChild(plannedLoadLift) // Add PlannedLift to the CraneSequence

                    }
                    
                }
                
                rootElement.addChild(cycleCraneSequence)
                
                writeXML(root: rootElement)

            }
        }
        
        
        CommonVariables.sharedInstance.edaContainers.removeAll()
        CommonVariables.sharedInstance.nmos.removeAll()
        CommonVariables.sharedInstance.pitchInCount = 0
        CommonVariables.sharedInstance.pitchOutCount = 0
        CommonVariables.sharedInstance.readyToGenerate = false
        
        
    }
    
    func writeXML(root: XMLElement) {
        
        let xml = XMLDocument(rootElement: root) // Create the XML document
        
        // Set the version, encoding, and content.
        // Set pretty print for readability.
        
        xml.version = "1.0"
        xml.characterEncoding = "UTF-8"
        xml.documentContentKind = .xml
        let data = xml.xmlData(options: .nodePrettyPrint)
        
        // Set the filename
        // Name: PitchLetter + DAY + MM-dd-YYYY HHmm
        
        df.dateFormat = "E MM-dd-YYYY HHmm"
        
        let fileName = "PitchLetter " + df.string(from: Date())
        
        // Set the path and create corresponding URL
        
        let path = AppDelegate.pitchLetterDirectory + fileName + ".xml"
        let url = URL(fileURLWithPath: path)
        
        // Write and open the XML
        
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            NSAlert(error: error).runModal()
        }
        
        NSWorkspace.shared.openFile(path, withApplication: "TextEdit")

    }
    
}
