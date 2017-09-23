//
//  RangedSpells.swift
//  Rune
//
//  Created by james bouker on 9/19/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import UIKit
import SpriteKit

class SpellSprite: SKSpriteNode {
    let directional: Bool
    let meta: SpellMeta

    required init?(coder aDecoder: NSCoder) {
        fatalError("Missing init with decoder")
    }

    init(spell: SpellMeta) {
        self.directional = spell.directional ?? false
        self.meta = spell
        super.init(texture: nil, color: .white, size: CGSize(width: tileSize, height: tileSize))
        anchorPoint = .zero
    }

    func spawnAndFire(loc: MapLocation, target: MapLocation, direction: Direction) {
        var images = [SKTexture]()
        for i in 1...meta.frames {
            let file = meta.asset + "_\(i)" + (directional ? "_\(direction.rawValue)" : "")
            let image = SKTexture.pixelatedImage(file: file)
            images.append(image)
        }
        guard let image = images.first else {
            fatalError("Could not load images for ranged spell \(meta.spellId)")
        }
        self.texture = image

        tileMap.addChild(self)
        if meta.frames > 1 {
            run(.repeatForever(.animate(with: images, timePerFrame: rangeTimePerTile / Double(meta.frames))))
        }
        self.setPosition(location: loc)

        var delta = target - loc
        let norm = delta.normalized
        delta -= norm
        position += CGPoint(x: CGFloat(norm.x) * tileSize/2.0, y: CGFloat(norm.y) * tileSize/2.0)

        let duration = Double(delta.length) * rangeTimePerTile
        runs([.moveBy(x: CGFloat(delta.x) * tileSize, y: CGFloat(delta.y) * tileSize, duration: duration), .removeFromParent()])
    }
}

class SpellMeta: Codable {
    let spellId: String
    let asset: String
    let frames: Int
    let directional: Bool?

    private var sprite: SpellSprite {
        return SpellSprite(spell: self)
    }

    func spawnAndFire(loc: MapLocation, target: MapLocation, direction: Direction) {
        sprite.spawnAndFire(loc: loc, target: target, direction: direction)
    }

    func duration(loc: MapLocation, target: MapLocation) -> TimeInterval {
        var delta = target - loc
        let norm = delta.normalized
        delta -= norm
        return Double(delta.length) * rangeTimePerTile
    }
}

class RangedSpells {
    var spells = [String : SpellMeta]()

    private static let shared = RangedSpells()
    private init() {
        spells = JSONLoader.createMap(resource: "Spells") { $0.spellId }
    }

    class func spell(forType type: String) -> SpellMeta {
        return shared.spells[type]!
    }
}
