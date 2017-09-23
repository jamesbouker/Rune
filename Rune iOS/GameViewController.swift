//
//  GameViewController.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/29/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import UIKit
import SpriteKit

var sharedController: GameViewController!
class GameViewController: UIViewController, Events {

    var scene: GameScene!
    var touchDownLocation: CGPoint?
    var touchDownTime: Date?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedController = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Storage.playerHealth = startingPlayerHealth
        guard let view = self.view as? SKView else { return }
        let scene = GameScene.loadScene()

        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill

        view.preferredFramesPerSecond = 60
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
        //        view.showsFPS = true
        //        view.showsNodeCount = true

        self.scene = view.scene as? GameScene
    }

    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        guard let view = self.view as? SKView else { return }
        guard let scene = view.scene as? GameScene else { return }
        scene.loadNextLevel()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let location = touches.first?.location(in: nil) else { return }
        touchDownLocation = location
        touchDownTime = Date()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touchDown = touchDownTime else { return }
        guard let to = touches.first?.location(in: nil) else { return }
        guard let from = touchDownLocation else { return }
        let time = Date().timeIntervalSince(touchDown)
        let delta: CGFloat = tileSize / 2
        let deltaX = (to - from).x
        let deltaY = (to - from).y

        let kill: () -> Void = {
            self.touchDownLocation = nil
            self.touchDownTime = nil
        }

        guard abs(deltaX) > delta || abs(deltaY) > delta else {
            if time > 0.3 {
                kill()
                fireEvent(event: .pressed)
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

    @IBAction func swipedUp() {
        fireEvent(event: .swipedUp)
    }

    @IBAction func swipedDown() {
        fireEvent(event: .swipedDown)
    }

    @IBAction func swipedLeft() {
        fireEvent(event: .swipedLeft)
    }

    @IBAction func swipedRight() {
        fireEvent(event: .swipedRight)
    }
}
