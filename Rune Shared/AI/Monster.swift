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

struct MonsterMeta {
    var monsterId: String
    var asset: String
    var ai: String
    var health: Int
    var isDirectional = true
    var range: Int?
    var canFly: Bool?
    var isRanged: Bool

    init?(json: [String: AnyObject], id: String) {
        range = json["range"] as? Int
        canFly = json["canFly"] as? Bool
        isRanged = json["isRanged"] as? Bool ?? false

        guard let health = json["maxHp"] as? Int,
            let asset = json["asset"] as? String,
            let ai = json["ai"] as? String,
            let directional = json["isDirectional"] as? Bool else {
            return nil
        }
        
        monsterId = id
        self.asset = asset
        self.ai = ai
        self.health = health
        isDirectional = directional
    }

    var monster: Monster {
        let aiImp = BaseAI.implementation(ai: ai, canFly: canFly, range: range, isRanged: isRanged)
        return Monster(monsterId: monsterId, maxHealth: health, asset: asset, ai: aiImp, isDirectional: isDirectional)
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

                    //TODO: Check range
                    if nextPlayer.isInline(mapLocation) && nextPlayer.distance(mapLocation) < self.ai.range! {
                        return .rangedAttack(sprite: player)
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

class JSONLoader {
    class func load(_ resource: String) -> [String: [String: AnyObject]] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            fatalError("Missing \(resource).json")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(resource).json")
        }
        let j = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let json = j as? [String: [String: AnyObject]] else {
            fatalError("Could not create json")
        }
        return json
    }
}

class MonsterManager {
    static let shared = MonsterManager()

    var monsters: [String: MonsterMeta]
    private init() {
        monsters = [String: MonsterMeta]()
        let json = JSONLoader.load("Monsters")
        for (key, monsterJSON) in json {
            monsters[key] = MonsterMeta(json: monsterJSON, id: key)
        }
    }

    class func monster(forType type: MonsterType) -> Monster {
        guard let monster = shared.monsters[type.rawValue] else {
            fatalError("Missing monster from json: \(type)")
        }
        return monster.monster
    }
}
