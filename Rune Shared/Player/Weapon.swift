//
//  Weapon.swift
//  Rune
//
//  Created by james bouker on 10/15/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import SpriteKit

class WeaponSprite: SKSpriteNode {
    enum WeaponMetal: String {
        case foo
        case bronze
        case iron
        case steel
        case mithril
        case black
        case fire
    }
    enum WeaponClass: String {
        case sword
        case axe
        case hammer
        case double_axe
        case broad_sword
        case deathbane
    }

    init(metal: WeaponMetal, weaponClass: WeaponClass) {
        let textureName = metal.rawValue + "_" + weaponClass.rawValue
        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: .white, size: texture.size())
    }

    func addToTileMap(chestLoc: MapLocation) {
        anchorPoint = .zero
        setPosition(location: chestLoc)

        // The texture for the crop mask
        let texture = SKSpriteNode(imageNamed: "chestEmptyBottom")
        texture.anchorPoint = .zero
        texture.setPosition(location: chestLoc)

        // This crops the weapon while it rises from the chest
        let cropNode = SKCropNode()
        cropNode.maskNode = texture
        cropNode.addChild(self)
        sharedController.scene.tileMap.addChild(cropNode)

        // Raises and Flicker!
        let duration = walkTime / 5.0
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let fadeIn = SKAction.fadeIn(withDuration: duration)
        let fade = SKAction.sequence([fadeOut, fadeIn, fadeOut, fadeIn, fadeOut])
        runs([.moveBy(x: 0, y: tileSize, duration: walkTime), .wait(forDuration: walkTime), fade])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
