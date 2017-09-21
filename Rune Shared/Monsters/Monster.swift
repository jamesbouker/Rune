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

    var monster: Monster {
        let aiImp = BaseAI.implementation(ai: ai, canFly: canFly, range: range, isRanged: isRanged, rangedItem: rangedItem)
        return Monster(monsterId: monsterId, maxHealth: maxHp, asset: asset, ai: aiImp, isDirectional: isDirectional)
    }
}

class Monster: Sprite {
    var ai: AI
    var asset: String
    var monsterId: String

    var action: SpriteAction?

    init(monsterId: String, maxHealth: Int, asset: String, ai: AI, isDirectional: Bool) {
        self.ai = ai
        self.asset = asset
        self.monsterId = monsterId
        super.init(maxHp: maxHealth)
        self.isDirectional = isDirectional

        guard let char = Character(rawValue: asset) else {
            fatalError("Character not supported: \(asset)")
        }
        character = char
    }

    func makeMove() -> ActionQueueType {
        guard let player = gameScene.player else { return .pass }
        let next = ai.nextMove(mapLocation)

        if next == player.nextLoc {
            return .attack(sprite: player)
        } else {
            if ai.isRanged == true {
                if let nextPlayer = player.nextLoc {
                    if nextPlayer.isInline(mapLocation) && nextPlayer.distance(mapLocation) < self.ai.range! {
                        let spell = RangedSpells.spell(forType: ai.rangedItem!)
                        return .rangedAttack(victim: player, spell: spell)
                    }
                }
                return .move(loc: next)
            } else {
                return .move(loc: next)
            }
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MonsterManager {
    static let shared = MonsterManager()

    var monsters: [String: MonsterMeta]
    private init() {
        monsters = JSONLoader.createMap(resource: "Monsters") { $0.monsterId }
    }

    class func monster(forType type: MonsterType) -> Monster {
        guard let monster = shared.monsters[type.rawValue] else {
            fatalError("Missing monster from json: \(type)")
        }
        return monster.monster
    }
}
