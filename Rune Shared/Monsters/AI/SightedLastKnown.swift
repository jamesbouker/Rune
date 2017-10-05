//
//  SightedLastKnown.swift
//  1 Bit Rogue
//
//  Created by james bouker on 9/7/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//
// swiftlint:disable large_tuple

import Foundation

class SightedLastKnown: SightedAI {
    var lastKnownPlayer: MapLocation?

    func findNextMove(_ from: Sprite) -> (loc: MapLocation, lostSight: Bool, endOfTheRoad: Bool) {
        // Can we spot the player?
        let next = super.nextMove(from: from, to: [nextPlayerLoc])
        let last = super.nextMove(from: from, to: [playerLoc])
        let toUse = super.nextMove(from: from, to: [nextPlayerLoc, playerLoc])

        let lostSight = next.sawPlayer == nil && last.sawPlayer != nil
        let end = from.mapLocation == lastKnownPlayer

        if let player = toUse.sawPlayer {
            // If so remember it for hunting them down!
            lastKnownPlayer = player
            return (toUse.loc, lostSight, false)
        }

        // Did not see the player
        if end {
            // We are standing on the last known location
            lastKnownPlayer = nil
        }

        let guess = super.nextMove(from: from, to: [lastKnownPlayer])
        return (guess.loc, lostSight, end)
    }

    override func nextMove(_ from: Sprite) -> MapLocation {
        return findNextMove(from).loc
    }
}
