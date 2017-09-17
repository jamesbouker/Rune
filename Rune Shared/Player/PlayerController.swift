//
//  PlayerController.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/4/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

extension Player {

    func flickerSquare() {
        let actions: [SKAction] = [.fadeIn(withDuration: walkTime / 2), .fadeOut(withDuration: walkTime / 2)]
        let seq = SKAction.sequence(actions)
        square.run(seq)
    }

    func moveLocation(_ delta: MapLocation) {
        guard !gameScene.isGameOver else {
            return
        }

        let newLoc = mapLocation + delta
        let tiles = tileMap.tileDefinitions(location: newLoc)
        guard tiles.count > 0 else { return }

        if tiles.isChestClosed {
            ActionQueue.shared.playerAction = .openChest(loc: newLoc)
        }

        // Switch - Show Stairs
        if tiles.isSwitch {
            ActionQueue.shared.playerAction = .hitSwitch(loc: newLoc)
        }

        if tiles.isStairsDown {
            afterDelay(walkTime, runBlock: { [weak self] in
                guard let strongSelf = self else { return }
                Storage.playerHealth = strongSelf.health
                strongSelf.gameScene.loadNextLevel()
            })
        }

        let next = delta + mapLocation
        if let monster = gameScene.monsterAt(next) {
            ActionQueue.shared.playerAction = .attack(sprite: monster)
        } else if tiles.isWalkable {
            // Move the player
            ActionQueue.shared.playerAction = .move(loc: next)
        }
    }

    func registerSwipes() {
        registerForEvent(.pressed, #selector(pressed))
        registerForEvent(.swipedUp, #selector(swipedUp))
        registerForEvent(.swipedDown, #selector(swipedDown))
        registerForEvent(.swipedLeft, #selector(swipedLeft))
        registerForEvent(.swipedRight, #selector(swipedRight))
    }

    @objc func pressed() {
        guard !gameScene.isGameOver else { return }
        flickerSquare()
        ActionQueue.shared.playerAction = .pass
    }

    @objc func swipedUp() {
        moveLocation(.init(x: 0, y: 1))
    }

    @objc func swipedDown() {
        moveLocation(.init(x: 0, y: -1))
    }

    @objc func swipedLeft() {
        moveLocation(.init(x: -1, y: 0))
    }

    @objc func swipedRight() {
        moveLocation(.init(x: 1, y: 0))
    }
}
