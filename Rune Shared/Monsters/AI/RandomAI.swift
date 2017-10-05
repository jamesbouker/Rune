//
//  RandomAI.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/28/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import Foundation

class RandomAI: BaseAI {
    override func nextMove(_ from: Sprite) -> MapLocation {
        guard let next = possibleMoves(from).randomItem() else {
            return from.mapLocation
        }
        return next
    }
}
