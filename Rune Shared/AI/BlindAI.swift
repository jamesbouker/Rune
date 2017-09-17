//
//  BlindAI.swift
//  1 Bit Rogue
//
//  Created by james bouker on 9/6/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import Foundation

class BlindAI: BaseAI {
    override func nextMove(_ from: MapLocation) -> MapLocation {
        let moves = possibleMoves(from)
        let playerLoc = moves.first { $0 == nextPlayerLoc }
        if let playerLoc = playerLoc {
            return playerLoc
        }
        return moves.randomItem() ?? from
    }
}
