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
    let numberFrames: Int
    let images: [SKTexture]

    required init?(coder aDecoder: NSCoder) {
        fatalError("Missing init with decoder")
    }

    init(spell: RangedSpell) {
        var images = [SKTexture]()
        for i in 1...spell.frames {
            let file = spell.asset + "_\(i)"
            let image = SKTexture.pixelatedImage(file: file)
            images.append(image)
        }
        self.images = images
        self.numberFrames = spell.frames
        let texture = images.first!
        super.init(texture: texture, color: .white, size: CGSize(width: tileSize, height: tileSize))
        anchorPoint = .zero
    }

    func spawnAndFire(loc: MapLocation, target: MapLocation) {
        tileMap.addChild(self)
        run(.repeatForever(.animate(with: images, timePerFrame: rangeTimePerTile / Double(self.numberFrames))))
        self.setPosition(location: loc)

        var delta = target - loc
        let norm = delta.normalized
        delta -= norm
        position += CGPoint(x: CGFloat(norm.x) * tileSize/2.0, y: CGFloat(norm.y) * tileSize/2.0)

        let duration = Double(delta.length) * rangeTimePerTile
        runs([.moveBy(x: CGFloat(delta.x) * tileSize, y: CGFloat(delta.y) * tileSize, duration: duration), .removeFromParent()])
    }
}

class RangedSpell: Codable {
    var rangeId: String
    var asset: String
    var frames: Int

    private var sprite: SpellSprite {
        return SpellSprite(spell: self)
    }

    func spawnAndFire(loc: MapLocation, target: MapLocation) {
        sprite.spawnAndFire(loc: loc, target: target)
    }

    func duration(loc: MapLocation, target: MapLocation) -> TimeInterval {
        var delta = target - loc
        let norm = delta.normalized
        delta -= norm
        return Double(delta.length) * rangeTimePerTile
    }
}

class RangedSpells {
    var spells = [String : RangedSpell]()

    private static let shared = RangedSpells()
    private init() {
        spells = JSONLoader.createMap(resource: "Range") { $0.rangeId }
    }

    class func spell(forType type: String) -> RangedSpell {
        return shared.spells[type]!
    }
}
