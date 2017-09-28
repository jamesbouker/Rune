//
//  Monster.swift
//  1 Bit Rogue
//
//  Created by james bouker on 9/5/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

enum MonsterType: String {
    case blackBat
    case blueSlime
    case brownBear
    case whiteRat
    case worm
    case skeleton
    case redDragon
}

class MonsterMeta: Codable {
    var monsterId: String
    var asset: String
    var ai: String
    var maxHp: Int
    var isDirectional: Bool
    var range: Int?
    var canFly: Bool?
    var isRanged: Bool?
    var rangedItem: String?
    var onDeath: String?

    var monster: Monster {
        return Monster(meta: self)
    }
}

class Monster: Sprite {
    var ai: AI
    var asset: String
    var monsterId: String
    var meta: MonsterMeta

    var action: SpriteAction?

    var remains: SKSpriteNode? {
        return MonsterManager.remains(forMonster: self)
    }

    init(meta: MonsterMeta) {
        self.meta = meta
        asset = meta.asset
        monsterId = meta.monsterId
        ai = BaseAI.implementation(meta: meta)
        super.init(maxHp: meta.maxHp)
        isDirectional = meta.isDirectional

        guard let char = Character(rawValue: meta.asset) else {
            fatalError("Character not supported: \(meta.asset)")
        }
        character = char
    }

    func makeMove() -> ActionQueueType {
        guard let player = gameScene.player else { return .pass }
        let next = ai.nextMove(mapLocation)

        if next == player.nextLoc {
            return .attack(victim: player)
        } else {
            if ai.isRanged == true {
                guard let nextPlayer = player.nextLoc else { return .move(loc: next) }
                if nextPlayer.isInline(mapLocation) && nextPlayer.distance(mapLocation) < ai.range! {
                    if tileMap.isWalkableFrom(start: next, target: nextPlayer) {
                        let spell = RangedSpells.spell(forType: ai.rangedItem!)
                        return .rangedAttack(victim: player, spell: spell)
                    }
                }
            }
        }
        return .move(loc: next)
    }

    override func die() {
        // Remove from monsters array
        let indx = gameScene.monsters.index { $0 === self }
        if let indx = indx {
            gameScene.monsters.remove(at: indx)
        }

        // Flicker!
        let duration = walkTime / 6.0
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let fadeIn = SKAction.fadeIn(withDuration: duration)
        let fade = SKAction.sequence([fadeOut, fadeIn, fadeOut])

        // Create remains sprite (Bones, blood, etc...)
        let loc = mapLocation
        if let death = self.remains {
            death.setPosition(location: loc)
            runs([fade, fade, .run {
                self.tileMap.items.addChild(death)
            }, .removeFromParent()])
        } else {
            runs([fade, fade, .removeFromParent()])
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MonsterRemainMeta: Codable {
    var deathId: String
    var numVariance: Int
}

class MonsterManager {
    static let shared = MonsterManager()

    var monsters: [String: MonsterMeta]
    var monsterRemains: [String: MonsterRemainMeta]

    private init() {
        monsters = JSONLoader.createMap(resource: "Monsters") { $0.monsterId }
        monsterRemains = JSONLoader.createMap(resource: "Death") { $0.deathId }
    }

    class func remains(forMonster monster: Monster) -> SKSpriteNode? {
        guard let onDeath = monster.meta.onDeath else { return nil }
        guard let death = shared.monsterRemains[onDeath] else {
            fatalError("Missing Monster Remains \(onDeath)")
        }

        let rand = Int.random(min: 1, max: death.numVariance)
        let texture = SKTexture.pixelatedImage(file: "\(death.deathId)_\(rand)")
        let node = SKSpriteNode(texture: texture, size: CGSize(width: tileSize, height: tileSize))
        node.anchorPoint = .zero
        return node
    }

    class func monster(forType type: MonsterType) -> Monster {
        guard let monster = shared.monsters[type.rawValue] else {
            fatalError("Missing monster from json: \(type)")
        }
        return monster.monster
    }
}
