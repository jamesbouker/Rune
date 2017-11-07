//
//  GameState.swift
//  Rune
//
//  Created by james bouker on 11/6/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

struct PlayerState: Codable, StateType {
    var loc: MapLocation
    var maxHealth: Int
    var health: Int
}

enum Item: UInt8, Codable, StateType {
    case chestOpen
    case chestEmpty
    case swicthOn
    case switchOff
    case stairs
}

struct MapState: Codable, StateType {
    var walls: [MapLocation]
    var items: [MapLocation : Item]
}

struct GameState: Codable, StateType {
    var playerState: PlayerState
    var mapState: MapState
}
