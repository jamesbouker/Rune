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
    var rangedItem: String?
    var isRanged: Bool
    var canFly = false

    init(meta: MonsterMeta) {
        canFly = meta.canFly ?? false
        isRanged = meta.isRanged ?? false
        rangedItem = meta.rangedItem ?? ""
        range = meta.range
    }

    func nextMove(_: Sprite) -> MapLocation {
        fatalError("Do not use this AI")
    }

    static func implementation(meta: MonsterMeta) -> AI {
        guard let aiType = AIType(rawValue: meta.ai) else {
            fatalError("\(meta.ai) does not exist as an AI Type")
        }
        let adjustedRange = meta.range != nil ? meta.range! + 2 : 0
        meta.range = adjustedRange

        switch aiType {
        case .random:
            return RandomAI(meta: meta)
        case .blind:
            return BlindAI(meta: meta)
        case .sighted:
            return SightedAI(meta: meta)
        case .sightedLastKnown:
            return SightedLastKnown(meta: meta)
        case .sightedFollower:
            return Follower(meta: meta)
        }
    }
}

protocol AI {
    var canFly: Bool { get set }
    var range: Int? { get set }
    var isRanged: Bool { get set }
    var rangedItem: String? { get set }

    func nextMove(_ from: Sprite) -> MapLocation
}

extension AI {
    var playerLoc: MapLocation {
        return sharedController.scene.player.mapLocation
    }

    var nextPlayerLoc: MapLocation? {
        return sharedController.scene.player.nextLoc
    }

    func possibleMoves(_ from: Sprite) -> [MapLocation] {
        let open: [MapLocation]
        if !canFly {
            open = sharedController!.scene.tileMap.playableNoMonsters
        } else {
            open = sharedController!.scene.tileMap.playableNoMonstersFlying
        }

        var locations = [MapLocation]()
        locations.append(.init(x: 1, y: 0) + from.mapLocation)
        locations.append(.init(x: -1, y: 0) + from.mapLocation)
        locations.append(.init(x: 0, y: 1) + from.mapLocation)
        locations.append(.init(x: 0, y: -1) + from.mapLocation)
        return locations.filter { open.contains($0) }
    }
}
