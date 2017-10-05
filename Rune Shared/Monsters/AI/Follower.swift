//
//  Follower.swift
//  1 Bit Rogue
//
//  Created by james bouker on 9/9/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import Foundation

class Follower: SightedLastKnown {
    var playerNextDirection: MapLocation?

    override func nextMove(_ from: Sprite) -> MapLocation {
        let found = findNextMove(from)

        // If just lost sight, remember the direction
        if found.lostSight {
            if let next = nextPlayerLoc {
                playerNextDirection = next - playerLoc
            }
        }

        // if at last known player pos AND we know the way...
        if found.endOfTheRoad {
            if let direction = playerNextDirection {
                return from.mapLocation + direction
            }
        }
        return found.loc
    }
}
