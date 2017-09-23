//
//  Characters.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/4/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

enum Character: String {
    case warrior
    case ranger
    case priest
    case berserker
    case thief
    case shaman
    case wizard

    case slime
    case bat
    case bear
    case rat
    case worm
    case skeleton
    case dragon
}

enum Direction: String {
    case u
    case d
    case l
    case r
}

extension Character {
    func animFrames(_ direction: Direction? = nil) -> SKAction {
        return .twoFrameAnim(pixelatedFile: rawValue, direction: direction?.rawValue)
    }
}
