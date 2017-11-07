//
//  GameScene.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/29/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import SpriteKit
import ReSwift

var store: Store<GameState> = Store(reducer: gameReducer, state: nil)

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
        _ = monsters.map {
            $0.nextLoc = nil
            $0.nextLocations = nil
        }

        _ = addActionHelper(1)
        _ = addActionHelper(2)
        for _ in 0 ... 5 {
            if !addActionHelper(3) {
                return
            }
        }
    }

    /// Returns true if we should try to run this again (A monster could not move)
    /// Determines all next monster actions
    func addActionHelper(_ step: Int) -> Bool {
        var didRemove = false
        for monster in monsters {
            guard monster.action == nil else { continue }
            let action = monster.makeMove()

            if case .attack = action {} else {
                if step == 1 {
                    // Can only assign attacks on first turn
                    continue
                }
            }

            if case .rangedAttack = action {} else {
                if case .attack = action {} else {

                    // Not ranged or attack!
                    if step == 2 {
                        // Can only assign attacks on first turn
                        continue
                    }
                }
            }
            monster.action = ActionQueue.shared.addAction(action, sprite: monster)

            // We did not move
            if monster.mapLocation == monster.nextLoc {

                // Remove any action moving to this location
                let first = monsters.first { $0.nextLoc == monster.nextLoc && $0 !== monster }
                if let firstAction = first?.action {
                    didRemove = true
                    first?.nextLoc = nil
                    first?.nextLocations = nil
                    ActionQueue.shared.removeAction(action: firstAction)
                }

                // Remove any action moving to 'these' actions
                guard let firingRange = monster.nextLocations else { continue }
                for m in monsters where m != monster {
                    if let mLoc = m.nextLoc, firingRange.contains(mLoc) {
                        didRemove = true

                        m.nextLoc = nil
                        m.nextLocations = nil
                        if let act = m.action {
                            ActionQueue.shared.removeAction(action: act)
                        }
                    }
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
