//
//  GameReducer.swift
//  Rune
//
//  Created by james bouker on 11/6/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

func gameReducer(action _: Action, state: GameState?) -> GameState {
    return state ?? GameState(playerLoc: MapLocation(x: 0, y: 0))
}
