//
//  AIs.swift
//  1 Bit Rogue
//
//  Created by james bouker on 9/6/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import Foundation

enum AIType: String {
    case random
    case blind
    case sighted
    case sightedLastKnown
    case sightedFollower
}

class BaseAI: AI {
    var range: Int?
    var isRanged: Bool?
    var canFly = false

    init(canFly: Bool?, range: Int?, isRanged: Bool?) {
        self.canFly = canFly ?? false
        self.isRanged = isRanged ?? false
        self.range = range
    }

    func nextMove(_: MapLocation) -> MapLocation {
        fatalError("Do not use this AI")
    }

    static func implementation(ai: String, canFly: Bool? = false, range: Int?, isRanged: Bool?) -> AI {
        guard let aiType = AIType(rawValue: ai) else {
            fatalError("\(ai) does not exist as an AI Type")
        }

        switch aiType {
        case .random:
            return RandomAI(canFly: canFly, range: range, isRanged: isRanged)
        case .blind:
            return BlindAI(canFly: canFly, range: range, isRanged: isRanged)
        case .sighted:
            guard let r = range else {
                fatalError("Missing range, creating sighted AI")
            }
            return SightedAI(range: r, canFly: canFly, isRanged: isRanged)
        case .sightedLastKnown:
            guard let r = range else {
                fatalError("Missing range, creating sighted AI")
            }
            return SightedLastKnown(range: r, canFly: canFly, isRanged: isRanged)
        case .sightedFollower:
            guard let r = range else {
                fatalError("Missing range, creating sighted AI")
            }
            return Follower(range: r, canFly: canFly, isRanged: isRanged)
        }
    }
}

protocol AI {
    var canFly: Bool { get set }
    var range: Int? { get set }
    var isRanged: Bool? { get set }
    func nextMove(_ from: MapLocation) -> MapLocation
}

extension AI {
    var playerLoc: MapLocation {
        return sharedController.scene.player.mapLocation
    }

    var nextPlayerLoc: MapLocation? {
        return sharedController.scene.player.nextLoc
    }

    func possibleMoves(_ from: MapLocation) -> [MapLocation] {
        let open: [MapLocation]
        if !canFly {
            open = sharedController!.scene.tileMap.playableNoMonsters
        } else {
            open = sharedController!.scene.tileMap.playableNoMonstersFlying
        }
        var locations = [MapLocation]()
        locations.append(.init(x: 1, y: 0) + from)
        locations.append(.init(x: -1, y: 0) + from)
        locations.append(.init(x: 0, y: 1) + from)
        locations.append(.init(x: 0, y: -1) + from)
        return locations.filter { open.contains($0) }
    }
}
