//
//  GameGenerator.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/10/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

class Level: Codable {
    private let width: Int
    private let widthVar: Int?
    private let height: Int
    private let heightVar: Int?
    private let atlas: String
    private let grass: Bool? = false
    let mustSpawn: [String]

    class func level(_ json: [String: AnyObject]) -> Level? {
        let jsonDecoder = JSONDecoder()
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }
        return try? jsonDecoder.decode(Level.self, from: data)
    }

    var minWidth: Int {
        let variance = widthVar ?? 0
        return width - Int.random(variance)
    }

    var maxWidth: Int {
        let variance = widthVar ?? 0
        return width + Int.random(variance)
    }

    var minHeight: Int {
        let variance = heightVar ?? 0
        return height - Int.random(variance)
    }

    var maxHeight: Int {
        let variance = heightVar ?? 0
        return height + Int.random(variance)
    }

    var env: EnvAtlas {
        guard let env = EnvAtlas(rawValue: atlas) else {
            fatalError("\(atlas) does not exist as EnvAtlas")
        }
        return env
    }
}

extension SKNode {
    func killMe() {
        for child in children {
            child.killMe()
        }
        removeAllActions()
        removeAllChildren()
        removeFromParent()
    }
}

extension GameScene {
    func loadNextLevel() {
        let json = JSONLoader.load("Levels")
        let nextLevel = levelNum + 1
        guard let levelJSON = json["\(nextLevel)"] else {
            return
        }
        guard let level = Level.level(levelJSON) else {
            return
        }
        ActionQueue.shared.game = nil
        print("Loading level: \(nextLevel)")

        let width = Int.random(min: level.minWidth, max: level.maxWidth)
        let height = Int.random(min: level.minHeight, max: level.maxHeight)
        let scene = generateGame(width: width, height: height, env: level.env)
        scene.levelNum = nextLevel

        for spawn in level.mustSpawn {
            guard let type = MonsterType(rawValue: spawn) else {
                fatalError("\(spawn) as Monster Type does not exist")
            }
            let monster = MonsterManager.monster(forType: type)
            scene.addMonster(monster)
        }

        let transition = SKTransition.doorway(withDuration: 1.0)
        view?.presentScene(scene, transition: transition)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.33) {
            self.cleanup()
            ActionQueue.shared.game = scene
        }
    }

    func cleanup() {
        for m in monsters {
            m.killMe()
        }
        monsters.removeAll()
        player.removeAllListeners()
        player.killMe()
        killMe()
    }

    func updateTiles() {
        tileMap.tileSet = SKTileSet(named: atlas.rawValue)!
        tileMap.tileSet.defaultTileSize = CGSize(width: tileSize, height: tileSize)
        tileMap.tileSize = CGSize(width: tileSize, height: tileSize)

        set(tiles: [.horz_wall, .vert_wall, .floor_hole], rule: "isWall")
        set(tile: .horz_wall, rule: "isHorz")
        set(tiles: [.stairs_down_solo, .stairs_down_black], rule: "stairs_down")
        set(tile: .floor_hole, rule: "isHole")
    }

    func set(tiles: [Tile], rule: String) {
        for t in tiles {
            set(tile: t, rule: rule)
        }
    }

    func set(tile: Tile, rule: String) {
        tileMap.set(value: true, forKey: rule, tile: tile, atlas: atlas)
    }

    func generateGame(width: Int, height: Int, env: EnvAtlas) -> GameScene {
        TileMeta.shared.reset()
        let game = GameScene(fileNamed: "GameScene")!
        sharedController.scene = game
        game.atlas = env
        game.grabOutlets()

        game.tileMap.numberOfColumns = width
        game.tileMap.numberOfRows = height

        let px = (CGFloat(width) * tileSize) * xScale / 2.0
        let py = (CGFloat(height) * tileSize) * yScale / 2.0
        game.tileMap.position.x = -px
        game.tileMap.position.y = -py

        game.tileMap.resetMaps()
        game.tileMap.setAllTiles(tile: .floor, atlas: env)

        let torches = (width + height) / 4
        game.addWallsAndItems(width: width, height: height)
        game.addLighting(torches: torches)
        game.addGrass()

        game.scaleMode = scaleMode

        return game
    }

    func addLighting(torches: Int) {
        var horz = tileMap.horzTorchableWalls
        horz.shuffle()

        for i in 0 ..< torches {
            let loc = horz[i]
            tileMap.sfx.setTile(tile: .torch, forLocation: loc)
            let locDown = MapLocation(x: loc.x, y: loc.y - 1)
            tileMap.sfx.setTile(tile: .torch_under, forLocation: locDown)
        }
    }

    func addGrass() {
        for loc in tileMap.walkables {
            let random = Int.random(100)
            if random > 20 { continue }
            if tileMap.sfx.tileDefinition(location: loc) == nil {
                tileMap.grass.setTile(tile: .grass, forLocation: loc)
            }
        }
    }

    func addItem(item: Tile) {
        if let loc = tileMap.corridors.randomItem() {
            tileMap.items.setTile(tile: item, forLocation: loc)
        }
    }

    func addWallsAndItems(width: Int, height: Int) {

        // set horizontal walls
        for x in 0 ..< width {
            tileMap.setTile(tile: .horz_wall, forLocation: MapLocation(x: x, y: 0), atlas: atlas)
            tileMap.setTile(tile: .horz_wall, forLocation: MapLocation(x: x, y: height - 1), atlas: atlas)
        }

        // set vertical walls
        for y in 1 ..< height {
            tileMap.setTile(tile: .vert_wall, forLocation: MapLocation(x: 0, y: y), atlas: atlas)
            tileMap.setTile(tile: .vert_wall, forLocation: MapLocation(x: width - 1, y: y), atlas: atlas)
        }

        let generator = Maze(width: width - 2, height: height - 2)

        for t in generator.walls {
            let randLoc = MapLocation(x: t.x + 1, y: t.y + 1)
            let randLocUp = MapLocation(x: t.x + 1, y: t.y + 2)
            let randLocDown = MapLocation(x: t.x + 1, y: t.y)

            // by default show horz wall
            var tile = Tile.horz_wall

            // if tile exists above, convert existing to vert wall
            if tileMap.tileDefinitions(location: randLocUp).isWall {
                tileMap.setTile(tile: .vert_wall, forLocation: randLocUp, atlas: atlas)
            }

            // if tile exists below, new tile should be vert
            if tileMap.tileDefinitions(location: randLocDown).isWall {
                tile = .vert_wall
            }

            if !tileMap.tileDefinitions(location: randLoc).isWall {
                tileMap.setTile(tile: tile, forLocation: randLoc, atlas: atlas)
            }
        }

        // Apply shadows
        let horz = tileMap.horzWalls
        for horzWallLoc in horz {
            let shadowLoc = MapLocation(x: horzWallLoc.x, y: horzWallLoc.y - 1)
            tileMap.shadows.setTile(tile: .shadow, forLocation: shadowLoc)
        }

        addItem(item: .switch_off)
        addItem(item: .chest_closed)

        player.setPosition(location: tileMap.walkableNoSprites.randomItem()!)
    }

    func showStairs() {
        let loc: MapLocation
        if let l = tileMap.corridors.randomItem() {
            loc = l
        } else {
            loc = tileMap.walkables.randomItem()!
        }

        let upOne = MapLocation(x: loc.x, y: loc.y + 1)
        let tileAbove = tileMap.tileDefinitions(location: upOne)

        let tileType: Tile
        if tileAbove.isHole {
            tileType = .stairs_down_black
        } else {
            tileType = .stairs_down_solo
        }
        tileMap.setTile(tile: tileType, forLocation: loc, atlas: atlas)

        // Clear grass, torch stuff, shadows
        tileMap.shadows.setTile(tile: .blank, forLocation: loc)
        tileMap.sfx.setTile(tile: .blank, forLocation: loc)
        tileMap.grass.setTile(tile: .blank, forLocation: loc)
    }
}