//
//  Commons.swift
//  Bullpen
//
//  Created by Joshua Kraft on 12/9/21.
//  Copyright © 2021 Joshua Kraft. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let allEDARequestsReceived : Notification.Name = Notification.Name("allEDARequestsReceived")
    static let nmoReceived : Notification.Name = Notification.Name("nmoReceived")
}

let TempQueueName = "/temp-queue/bullpen-temp-eda-queue"

let bullpenConsumer = BullpenConsumer()

var pitchInCount = 0
var pitchOutCount = 0

var readyToGenerate = false

var edaContainers = [EDAContainer]()
var nmos = [String]()

func stompClient() -> StompClient {
    return NSApplication.shared.stompClient
}

func requestEDAContainers(names: [String]) {
    let ecr = EDAContainerRequest()
    ecr.serializeResults = false
    ecr.nameArray = names
    let frame = StompXocFrame(object: ecr)
    frame?.userHeaders["terminalCode"] = "LAX"
    frame?.destination = "/queue/EDAService"
    frame?.replyTo = TempQueueName
    stompClient().send(frame)
}
