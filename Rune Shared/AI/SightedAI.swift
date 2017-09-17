//
//  SightedAI.swift
//  1 Bit Rogue
//
//  Created by james bouker on 9/6/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import Foundation

class SightedAI: BaseAI {
    let range: Int

    init(range: Int, canFly: Bool?) {
        self.range = range
        super.init(canFly: canFly)
    }

    func nextMove(from: MapLocation, to: MapLocation?) -> MapLocation? {
        guard let to = to else { return nil }
        let moves = possibleMoves(from)

        // see if we can see the player
        var delta = to - from
        guard delta.x == 0 || delta.y == 0 else {
            return nil
        }

        // One of these is 0
        let distance = delta.x != 0 ? abs(delta.x) : abs(delta.y)
        if delta.x == 0 {
            delta.y = delta.y > 0 ? 1 : -1
        } else {
            delta.x = delta.x > 0 ? 1 : -1
        }

        if distance < range {
            var loc = from
            for _ in 1 ... distance {
                loc += delta
                if !canFly && !sharedController.scene.tileMap.tileDefinitions(location: loc).isWalkable {
                    return nil
                }
            }
            let next = from + delta
            if moves.contains(next) {
                return next
            }
        }
        return nil
    }

    func nextMove(from: MapLocation, to: [MapLocation?]) -> (loc: MapLocation, sawPlayer: MapLocation?) {

        for t in to {
            guard let t = t else { continue }
            if let next = nextMove(from: from, to: t) {
                return (next, t)
            }
        }
        return (possibleMoves(from).randomItem() ?? from, nil)
    }

    override func nextMove(_ from: MapLocation) -> MapLocation {
        return nextMove(from: from, to: [nextPlayerLoc, playerLoc]).loc
    }
}
