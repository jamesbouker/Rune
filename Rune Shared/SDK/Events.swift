//
//  Events.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/29/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import Foundation

// MARK: - Event Types

enum EventType: String {
    case pressed
    case swipedUp
    case swipedDown
    case swipedRight
    case swipedLeft
    case gameOver
}

// MARK: - Implementation

typealias Handler = () -> Void
protocol Events {
    func registerForEvent(_ event: EventType, _ sel: Selector)
    func removeEventListener(event: EventType)

    func fireEvent(event: EventType)
}

extension Events {

    var center: NotificationCenter {
        return NotificationCenter.default
    }

    func note(_ event: EventType) -> Notification.Name {
        return Notification.Name(rawValue: event.rawValue)
    }

    func fireEvent(event: EventType) {
        let name = note(event)
        center.post(name: name, object: nil)
    }

    func registerForEvent(_ event: EventType, _ sel: Selector) {
        let name = note(event)
        center.addObserver(self, selector: sel, name: name, object: nil)
    }

    func removeEventListener(event: EventType) {
        let name = note(event)
        center.removeObserver(self, name: name, object: nil)
    }

    func removeAllListeners() {
        center.removeObserver(self)
    }
}
