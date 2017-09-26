//
//  InterfaceController.swift
//  Rune watchOS Extension
//
//  Created by james bouker on 9/25/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import WatchKit
import Foundation

var sharedController: InterfaceController!
class InterfaceController: WKInterfaceController, Events {

    @IBOutlet var skInterface: WKInterfaceSKScene!
    var scene: GameScene!
    var touchDownTime: Date?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        Storage.playerHealth = startingPlayerHealth
        sharedController = self

        let scene = GameScene.loadScene()
        scene.scaleMode = .aspectFill
        self.skInterface.preferredFramesPerSecond = 60
        self.skInterface.presentScene(scene)

        self.scene = scene
    }

    var initialLocation: CGPoint?
    @IBAction func screenLongPressed(gesture: WKLongPressGestureRecognizer) {
        if gesture.state == .began {
            initialLocation = gesture.locationInObject()
        }
        if gesture.state == .ended, let loc = initialLocation {
            let delta = gesture.locationInObject() - loc
            if delta.lengthSquared() < 100 {
                fireEvent(event: .pressed)
            }
        }
    }

    @IBAction func screenPanned(_ gesture: WKPanGestureRecognizer) {
        if touchDownTime == nil {
            print("Gesture.state: \(gesture.state)")
            touchDownTime = Date()
            return
        }

        if gesture.state != .ended {
            return
        }

        guard let touchDown = touchDownTime else { return }
        let time = Date().timeIntervalSince(touchDown)
        let delta: CGFloat = tileSize / 2
        let deltaX = gesture.translationInObject().x
        let deltaY = gesture.translationInObject().y

        let kill: () -> Void = {
            self.touchDownTime = nil
        }

        guard abs(deltaX) > delta || abs(deltaY) > delta else {
            if time > 0.3 {
                kill()
            }
            return
        }

        if abs(deltaX) > abs(deltaY) {
            if deltaX > delta {
                kill()
                fireEvent(event: .swipedRight)
            } else if deltaX < -delta {
                kill()
                fireEvent(event: .swipedLeft)
            }
        } else {
            if deltaY > delta {
                kill()
                fireEvent(event: .swipedDown)
            } else if deltaY < -delta {
                kill()
                fireEvent(event: .swipedUp)
            }
        }
    }
}
