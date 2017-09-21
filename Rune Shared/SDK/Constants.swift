//
//  Constants.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/2/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

typealias Completion = () -> Void

// Taken from GameScene.sks Base.tileSize and TileSet tile size
let tileSize: CGFloat = 48.0

// Amount of time between 2 key frame animations
let frameTime = 0.25

// Amount of time spent moving between two tiles
let walkTime = 0.20

// The health the Player starts the game with
let startingPlayerHealth = 100

// Show debug colors / values
let debug = false

// The amount of time a ranged spell moves across a tile
let rangeTimePerTile = 0.15
