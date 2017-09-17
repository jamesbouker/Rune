//
//  Player.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/29/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

class Player: Sprite, ChildNode, Events {
    var square: SKShapeNode!

    func didMoveToScene(scene _: GameScene) {
        maxHelath = startingPlayerHealth
        health = Storage.playerHealth
        character = Character.wizard
        guard let sq = childNode(withName: "square") as? SKShapeNode else {
            fatalError("Player missing the square for trun passes")
        }
        square = sq
        square.alpha = 0
        run(character.animFrames(.l), type: .twoFrame)
        registerSwipes()
    }

    override func die() {
        removeAction(forType: .twoFrame)
        texture = Assets.rip
        fireEvent(event: .gameOver)
    }
}
