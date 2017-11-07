//
//  GameReducer.swift
//  Rune
//
//  Created by james bouker on 11/6/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

func mapReducer(action: Action, state: MapState?) -> MapState {
    return state ?? MapState(walls: [], items: [:])
}

func playerReducer(action: Action, state: PlayerState?) -> PlayerState {
    return state ?? PlayerState(loc: MapLocation(x: 0, y: 0), maxHealth: 100, health: 100)
}

func gameReducer(action: Action, state: GameState?) -> GameState {
    return GameState(playerState: playerReducer(action: action, state: state?.playerState),
                     mapState: mapReducer(action: action, state: state?.mapState))
}
