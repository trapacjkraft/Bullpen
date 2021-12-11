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
            if !edaContainers.contains(eda) {
                edaContainers.append(eda)
                if edaContainers.count + nmos.count == pitchInCount + pitchOutCount {
                    NotificationCenter.default.post(name: .allEDARequestsReceived, object: nil)
                }
            }
        }
    }
    
    @objc func receiveNoMatchingObjects(_ nmo: NoMatchingObjects) {
        print("Received NoMatchingObject with content: \(nmo.content ?? "none")\n\n")
        DispatchQueue.main.async {
            if !nmos.contains(nmo.content) {
                nmos.append(nmo.content)
                NotificationCenter.default.post(name: .nmoReceived, object: nil)
            }
            if edaContainers.count + nmos.count == pitchInCount + pitchOutCount {
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
    
}
