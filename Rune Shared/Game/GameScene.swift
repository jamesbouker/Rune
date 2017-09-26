//
//  GameScene.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/29/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, ActionQueueDelegate, Events {
    var levelNum = 0
    var tileMap: SKTileMapNode!
    var itemsMap: SKTileMapNode!
    var player: Player!
    var monsters = [Monster]()
    var isGameOver = false
    var atlas = EnvAtlas.vine

    class func loadScene() -> GameScene {
        let scene = GameScene(fileNamed: "GameScene")!
        scene.levelNum = 1
        ActionQueue.shared.game = scene
        return scene
    }

    #if os(watchOS)
        override func sceneDidLoad() {
            setupView()
        }

    #else
        override func didMove(to _: SKView) {
            setupView()
        }
    #endif

    func setupView() {
        grabOutlets()
        notifyChildrenOfMove()
        tileMap.pixelate()
        registerForEvent(.gameOver, #selector(gameOver))
    }

    @objc func gameOver() {
        isGameOver = true
    }

    func grabOutlets() {
        tileMap = childNode(withName: "Base") as? SKTileMapNode
        itemsMap = tileMap.items
        player = tileMap.childNode(withName: "Player") as? Player
        updateTiles()
    }
}

extension GameScene {
    func addActions() {
        for _ in 0 ... 5 {
            if !addActionHelper() {
                return
            }
        }
    }

    /// Returns true if we should try to run this again (A monster could not move)
    /// Determines all next monster actions
    func addActionHelper() -> Bool {
        var didRemove = false
        for monster in monsters {
            guard monster.action == nil else { continue }
            let action = monster.makeMove()
            let spriteAction = ActionQueue.shared.addAction(action, sprite: monster)
            monster.action = spriteAction

            // We did not move
            if monster.mapLocation == monster.nextLoc {

                // Remove any action moving to this location
                let first = monsters.first { $0.nextLoc == monster.nextLoc && $0 !== monster }
                if let firstAction = first?.action {
                    didRemove = true
                    ActionQueue.shared.removeAction(action: firstAction)
                }
            }
        }
        return didRemove
    }

    func addMonster(_ sprite: Monster) {
        let loc: MapLocation?
        if !sprite.ai.canFly {
            loc = tileMap.walkableNoSprites.randomItem()
        } else {
            //            loc = tileMap.locationsNoMonsters.randomItem()
            loc = tileMap.walkableNoSprites.randomItem()
        }
        guard let l = loc else {
            return
        }
        sprite.setPosition(location: l)
        tileMap.addChild(sprite)
        monsters.append(sprite)
    }

    func monsterAt(_ location: MapLocation) -> Sprite? {
        return monsters.first { $0.mapLocation == location }
    }
}
