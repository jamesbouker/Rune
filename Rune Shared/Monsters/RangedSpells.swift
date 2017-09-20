//
//  RangedSpells.swift
//  Rune
//
//  Created by james bouker on 9/19/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import UIKit

class RangedSpell: Codable {
    var rangeId: String
    var frames: Int
    var timePerFrame: CGFloat
}

class RangedSpells {
    var spells = [String : RangedSpell]()

    static let shared = RangedSpells()
    private init() {
        spells = JSONLoader.createMap(resource: "Range") { $0.rangeId }
    }
}
