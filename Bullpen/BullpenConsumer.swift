//
//  BullpenConsumer.swift
//  Bullpen
//
//  Created by Joshua Kraft on 12/9/21.
//  Copyright © 2021 Joshua Kraft. All rights reserved.
//

import Cocoa

@objc class BullpenConsumer: StompXMLConsumer {

    @objc func receiveEDAContainer(_ eda: EDAContainer) {
        DispatchQueue.main.async {
            if !CommonVariables.sharedInstance.edaContainers.contains(eda) {
                CommonVariables.sharedInstance.edaContainers.append(eda)
                if CommonVariables.sharedInstance.edaContainers.count + CommonVariables.sharedInstance.nmos.count == CommonVariables.sharedInstance.pitchInCount + CommonVariables.sharedInstance.pitchOutCount {
                    NotificationCenter.default.post(name: .allEDARequestsReceived, object: nil)
                }
            }
        }
    }
    
    @objc func receiveNoMatchingObjects(_ nmo: NoMatchingObjects) {
        DispatchQueue.main.async {
            if !CommonVariables.sharedInstance.nmos.contains(nmo.content) {
                CommonVariables.sharedInstance.nmos.append(nmo.content)
                NotificationCenter.default.post(name: .nmoReceived, object: nil)
            }
            if CommonVariables.sharedInstance.edaContainers.count + CommonVariables.sharedInstance.nmos.count == CommonVariables.sharedInstance.pitchInCount + CommonVariables.sharedInstance.pitchOutCount {
                NotificationCenter.default.post(name: .allEDARequestsReceived, object: nil)
            }
        }
    }
    
    @objc func receiveXocAnyElement(_ anObject: XocAnyElement?) {
        guard let nodeName = anObject?.rootNodeName() else {
            print("missing node name")
            return
        }
        print("Unsupported message \(nodeName)")
    }
    
    override func thread() -> Thread! {
        return Thread.main
    }
    
}
