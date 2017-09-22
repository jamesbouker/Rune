//
//  Sprite.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/29/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    var mapLocation: MapLocation {
        return tileMap.mapLocation(fromPosition: position + CGPoint(x: tileSize / 2, y: tileSize / 2))
    }

    var tileMap: SKTileMapNode {
        return gameScene.tileMap
    }

    var itemsMap: SKTileMapNode {
        return tileMap.items
    }

    var gameScene: GameScene {
        return sharedController!.scene
    }

    func setPosition(location: MapLocation) {
        position = tileMap.mapPosition(fromLocation: location)
        position -= CGPoint(x: tileSize / 2, y: tileSize / 2)
    }
}

class Sprite: SKSpriteNode {
    var maxHelath: Int
    var health: Int
    var isDirectional = true
    var lastDirection: Direction?

    required init?(coder aDecoder: NSCoder) {
        character = .wizard
        maxHelath = 1
        health = maxHelath
        super.init(coder: aDecoder)
    }

    convenience init(location: MapLocation, maxHp: Int) {
        self.init(maxHp: maxHp)
        setPosition(location: location)
    }

    init(maxHp: Int) {
        character = .wizard
        maxHelath = maxHp
        health = maxHelath
        let texture = SKTexture.pixelatedImage(character: character, direction: .l)
        super.init(texture: texture, color: .white, size: .init(width: tileSize, height: tileSize))
        anchorPoint = .zero
    }

    var character: Character {
        didSet {
            removeAction(forType: .twoFrame)
            run(character.animFrames(isDirectional ? .l : nil), type: .twoFrame)
        }
    }

    var nextLoc: MapLocation?

    func updateImages(_ deltaX: Int) {
        guard abs(deltaX) > 0 else { return }
        let type: Direction = deltaX > 0 ? .r : .l
        if lastDirection == type {
            return
        }
        lastDirection = type
        removeAction(forType: .twoFrame)
        if isDirectional {
            let type: Direction = deltaX > 0 ? .r : .l
            run(character.animFrames(type), type: .twoFrame)
        } else {
            run(character.animFrames(), type: .twoFrame)
        }
    }

    func fire(spell: RangedSpell, at victim: Sprite) {
        spell.spawnAndFire(loc: mapLocation, target: victim.nextLoc!)
    }

    func die() {
        fatalError("Please Override")
    }
}
