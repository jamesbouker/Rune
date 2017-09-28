//
//  ActionQueue.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/30/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

import SpriteKit

enum ActionQueueType {
    case move(loc: MapLocation)
    case pass
    case attack(victim: Sprite)
    case rangedAttack(victim: Sprite, spell: SpellMeta)
    case openChest(loc: MapLocation)
    case hitSwitch(loc: MapLocation)
    case none

    func hit(attacker: Sprite, victim: Sprite, target: MapLocation?) -> SKAction {
        let victimLoc = target ?? victim.mapLocation
        let delta = victimLoc - attacker.mapLocation
        return bump(delta) { [weak victim] in
            guard let strongVictim = victim else { return }
            strongVictim.health -= 1
            if strongVictim.health <= 0 {
                strongVictim.die()
            }
        }
    }

    func bump(_ delta: MapLocation, mid: Completion? = nil) -> SKAction {
        let delta = delta.normalized
        let duration = walkTime / 2
        let mult = tileSize / 4
        let by = CGVector(dx: mult * CGFloat(delta.x), dy: mult * CGFloat(delta.y))
        let back = CGVector(dx: -mult * CGFloat(delta.x), dy: -mult * CGFloat(delta.y))
        let firstMove = SKAction.move(by: by, duration: duration)
        let secondMove = SKAction.move(by: back, duration: duration)
        let seq = [firstMove, SKAction.run {
            mid?()
        }, secondMove]
        return SKAction.sequence(seq)
    }

    func skAction(action: ActionQueueType, sprite: Sprite, target: MapLocation? = nil) -> SKAction? {
        guard sprite.health > 0 else { return nil }
        switch action {
        case let .move(loc):
            let delta = loc - sprite.mapLocation
            return .group([.run { [weak sprite] in
                sprite?.updateImages(delta.x)
            }, .moveBy(x: CGFloat(delta.x) * tileSize, y: CGFloat(delta.y) * tileSize, duration: walkTime)])
        case let .rangedAttack(victim, spell):
            let victimLoc = target ?? victim.mapLocation
            let delta = victimLoc - sprite.mapLocation
            return .group([.run { [weak sprite] in
                sprite?.updateImages(delta.x)
                sprite?.fire(spell: spell, at: victimLoc)
            }, hit(attacker: sprite, victim: victim, target: victimLoc)])
        case let .attack(victim):
            let victimLoc = target ?? victim.mapLocation
            let delta = victimLoc - sprite.mapLocation
            return .group([.run { [weak sprite] in
                sprite?.updateImages(delta.x)
            }, hit(attacker: sprite, victim: victim, target: victimLoc)])
        case let .openChest(loc):
            sprite.tileMap.items.setTile(tile: .chest_empty, forLocation: loc)
            let delta = loc - sprite.mapLocation
            return .group([.run { [weak sprite] in
                sprite?.updateImages(delta.x)
            }, bump(delta)])
        case let .hitSwitch(loc):
            let tiles = sprite.tileMap.tileDefinitions(location: loc)
            if !tiles.switchOn {
                sprite.itemsMap.setTile(tile: .switch_on, forLocation: loc)
                sprite.gameScene.showStairs()
            }
            let delta = loc - sprite.mapLocation
            return .group([.run { [weak sprite] in
                sprite?.updateImages(delta.x)
            }, bump(delta)])
        case .pass:
            return .wait(forDuration: walkTime)
        default:
            return nil
        }
    }
}

protocol ActionQueueDelegate: class {
    func addActions()
}

class SpriteAction {
    let sprite: Sprite
    let action: ActionQueueType
    let duration: TimeInterval
    let target: MapLocation?

    init(sprite: Sprite, action: ActionQueueType) {
        self.sprite = sprite
        self.action = action

        switch action {
        case let .attack(victim):
            target = victim.nextLoc ?? victim.mapLocation
            duration = walkTime
        case let .rangedAttack(victim, spell):
            target = victim.nextLoc ?? victim.mapLocation
            duration = spell.duration(loc: sprite.mapLocation, target: target!)
        default:
            target = nil
            duration = walkTime
        }
    }

    var skAction: SKAction? {
        return action.skAction(action: action, sprite: sprite, target: target)
    }
}

class ActionQueue {
    static let shared = ActionQueue()

    weak var game: GameScene? {
        didSet {
            cleanup()
            delegate = game
            isExecuting = false
        }
    }

    private weak var delegate: ActionQueueDelegate?

    private var isExecuting: Bool = false
    private var enemyActions = [SpriteAction]()

    func cleanup() {
        enemyActions.removeAll()
        playerAction = nil
    }

    var playerAction: ActionQueueType? = .none {
        didSet {
            guard let game = self.game else { return }
            guard let action = playerAction else { return }

            guard case .none = action else {
                switch action {
                case let .move(loc):
                    game.player.nextLoc = loc
                default:
                    game.player.nextLoc = game.player.mapLocation
                }
                if !isExecuting {
                    execute()
                }
                return
            }
        }
    }

    private init() {}

    func addAction(_ action: ActionQueueType, sprite: Sprite) -> SpriteAction {
        switch action {
        case let .move(loc):
            sprite.nextLoc = loc
        default:
            sprite.nextLoc = sprite.mapLocation
        }

        let sAction = SpriteAction(sprite: sprite, action: action)
        enemyActions.append(sAction)
        return sAction
    }

    func removeAction(action: SpriteAction) {
        let i = enemyActions.index { $0 === action }
        if let index = i {
            enemyActions.remove(at: index)
        }
    }

    /// This will build and exectute all SKActions
    private func execute() {
        var nothingAttacked = true

        // Here to prevent retain cycle when current GameScene is unloaded (aka next level)
        guard let game = self.game else {
            cleanup()
            return
        }
        guard let playerAction = self.playerAction else {
            return
        }
        guard let playerAct = playerAction.skAction(action: playerAction, sprite: game.player) else {
            return
        }

        isExecuting = true
        self.playerAction = .none
        enemyActions.removeAll()
        delegate?.addActions()
        _ = game.monsters.map {
            $0.action = nil
        }

        // Attacked enemy? This one should not move w/ the player
        var attackedEnemy: Sprite?
        if case let .attack(enemy) = playerAction {
            nothingAttacked = false
            attackedEnemy = enemy
        }

        // Find all enemies that should move at the same time as the player
        var movingEnemies = [SpriteAction]()

        // Move after the player
        var moveAfter = [SpriteAction]()

        // Attack the player
        var attackingEnemies = [SpriteAction]()

        for act in enemyActions {
            if case .move = act.action {
                if act.sprite != attackedEnemy {
                    movingEnemies.append(act)
                } else {
                    moveAfter.append(act)
                }
            } else if case .attack = act.action {
                nothingAttacked = false
                attackingEnemies.append(act)
            } else if case .rangedAttack = act.action {
                nothingAttacked = false
                attackingEnemies.append(act)
            }
        }

        // Move the player and everyone else allowed
        game.player.runs([playerAct, .run { [weak self] in
            guard let strongSelf = self else { return }

            // Wait for player to move, then move all remaining in sequence
            var anEnemyDidWalk = false
            for enemy in moveAfter {
                if let enemyAct = enemy.skAction {
                    enemy.sprite.run(enemyAct)
                    anEnemyDidWalk = true
                }
            }

            // Iterate through enemies and attack
            var waitTime = 0.0
            for attacker in attackingEnemies {
                if let act = attacker.skAction {
                    attacker.sprite.runs([SKAction.wait(forDuration: waitTime), act])
                    waitTime += attacker.duration
                }
            }

            // End it all
            if anEnemyDidWalk {
                waitTime += walkTime
            }
            game.afterDelay(waitTime + 1.0 / 30.0) { [weak strongSelf] in
                if nothingAttacked {
                    guard case .none = strongSelf?.playerAction else {
                        strongSelf?.execute()
                        return
                    }
                }
                strongSelf?.isExecuting = false
            }
        }])

        for enemy in movingEnemies {
            if let enemyAct = enemy.skAction {
                enemy.sprite.run(enemyAct)
            }
        }
    }
}
