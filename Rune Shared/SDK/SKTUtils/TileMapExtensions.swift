//
//  TileMapExtensions.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/31/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//
// swiftlint:disable shorthand_operator
// swiftlint:disable operator_whitespace
// swiftlint:disable line_length
// swiftlint:disable file_length

import SpriteKit
import ObjectiveC

enum Tile: String {
    case blank
    case floor
    case floor_hole
    case vert_wall
    case horz_wall
    case switch_on
    case switch_off
    case stairs_down_black
    case stairs_down_solo
    case chest_closed
    case chest_empty
    case chest_open
    case shadow
    case torch
    case torch_under
    case grass
    case fire
}

struct MapLocation: Equatable {
    var x: Int
    var y: Int

    static func ==(lhs: MapLocation, rhs: MapLocation) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    static func +(lhs: MapLocation, rhs: MapLocation) -> MapLocation {
        return MapLocation(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: MapLocation, rhs: MapLocation) -> MapLocation {
        return MapLocation(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func +=(lhs: inout MapLocation, rhs: MapLocation) {
        lhs = lhs + rhs
    }

    static func -=(lhs: inout MapLocation, rhs: MapLocation) {
        lhs = lhs - rhs
    }

    func isInline(_ loc: MapLocation) -> Bool {
        let delta = loc - self
        return delta.x == 0 || delta.y == 0
    }

    func distance(_ loc: MapLocation) -> Int {
        return (loc.x - x) + (loc.y - y)
    }

    var length: Int {
        return abs(x) + abs(y)
    }

    var normalized: MapLocation {
        if x == 0 && y == 0 {
            return MapLocation(x: 0, y: 0)
        } else if abs(x) > 0 {
            return MapLocation(x: x > 0 ? 1 : -1, y: 0)
        } else {
            return MapLocation(x: 0, y: y > 0 ? 1 : -1)
        }
    }
}

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    static func +=(lhs: inout CGPoint, rhs: CGSize) {
        lhs = lhs + rhs
    }
}

class TileMeta {
    static let shared = TileMeta()
    fileprivate var locations: [MapLocation]?
    fileprivate var itemLocations: [MapLocation]?
    fileprivate var walkables: [MapLocation]?

    func reset() {
        locations = nil
        itemLocations = nil
        walkables = nil
    }
}

extension SKTileMapNode {

    var locations: [MapLocation] {
        if let loc = TileMeta.shared.locations {
            return loc
        }
        var locs = [MapLocation]()
        for x in 0 ..< numberOfColumns {
            for y in 0 ..< numberOfRows {
                locs.append(MapLocation(x: x, y: y))
            }
        }
        TileMeta.shared.locations = locs
        return locs
    }

    var locationsNoMonsters: [MapLocation] {
        return locations.filter { !monsterLocations.contains($0) }
    }

    var monsters: [Sprite] {
        return sharedController.scene.monsters
    }

    var monsterLocations: [MapLocation] {
        return monsters.map { $0.mapLocation }
    }

    var monsterNextLocations: [MapLocation] {
        return monsters.flatMap { $0.nextLoc }
    }

    var itemLocations: [MapLocation] {
        if let i = TileMeta.shared.itemLocations {
            return i
        }
        TileMeta.shared.itemLocations = locations.filter { items.tileDefinition(location: $0) != nil }
        return TileMeta.shared.itemLocations!
    }

    var walls: [MapLocation] {
        return locations.filter { tileDefinitions(location: $0).isWall }
    }

    var horzWalls: [MapLocation] {
        return locations.filter { tileDefinitions(location: $0).isHorz }
    }

    var horzTorchableWalls: [MapLocation] {
        return horzWalls.filter { $0.y > 0 }
    }

    var walkables: [MapLocation] {
        if let w = TileMeta.shared.walkables {
            return w
        }
        TileMeta.shared.walkables = locations.filter { tileDefinitions(location: $0).isWalkable }
        return TileMeta.shared.walkables!
    }

    var walkableNoSprites: [MapLocation] {
        let monsters = walkableNoMonsters
        return monsters.filter { $0 != sharedController.scene.player.mapLocation }
    }

    var walkableNoMonsters: [MapLocation] {
        let monsters = monsterLocations
        return walkables.filter { !monsters.contains($0) }
    }

    var playableNoMonsters: [MapLocation] {
        var cantWalk = monsterNextLocations
        cantWalk.append(contentsOf: itemLocations)
        return walkables.filter { !cantWalk.contains($0) }
    }

    var playableNoMonstersFlying: [MapLocation] {
        var cantWalk = monsterNextLocations
        cantWalk.append(contentsOf: itemLocations)
        return locations.filter { !cantWalk.contains($0) }
    }

    func resetMaps() {
        setAllTiles(tile: .blank)

        for child in children {
            if let map = child as? SKTileMapNode {
                map.numberOfRows = numberOfRows
                map.numberOfColumns = numberOfColumns
                map.position = .zero
                map.resetMaps()
            }
        }
    }

    func group(_ tile: Tile, atlas: String? = nil) -> SKTileGroup? {
        return tileSet.tileGroups.filter {
            var name = (atlas != nil) ? atlas! + "_" : ""
            name += tile.rawValue
            print("$0.name: \($0.name ?? "")")
            print("name: \(name)")
            return $0.name == name
        }.first
    }

    func setTile(tile: Tile, forPosition: CGPoint) {
        let loc = mapLocation(fromPosition: forPosition)
        setTile(tile: tile, forLocation: loc)
    }

    func setTile(tile: Tile, forLocation: MapLocation, atlas: EnvAtlas? = nil) {
        if let group = group(tile, atlas: atlas?.rawValue) {
            setTileGroup(group, forColumn: forLocation.x, row: forLocation.y)
        } else {
            setTileGroup(nil, forColumn: forLocation.x, row: forLocation.y)
        }
    }

    func setAllTiles(tile: Tile, atlas: EnvAtlas = .stone) {
        for x in 0 ..< numberOfColumns {
            for y in 0 ..< numberOfRows {
                setTile(tile: tile, forLocation: .init(x: x, y: y), atlas: atlas)
            }
        }
    }

    func set(value: Bool, forKey: String, tile: Tile, atlas: EnvAtlas = .stone) {
        let name = atlas.rawValue + "_" + tile.rawValue

        for g in tileSet.tileGroups {
            guard g.name == name else { continue }
            for r in g.rules {
                for def in r.tileDefinitions {
                    if def.userData == nil {
                        def.userData = NSMutableDictionary()
                    }
                    def.userData?.setValue(value, forKey: forKey)
                }
            }
        }
    }

    func pixelate() {
        _ = tileSet.tileGroups.map { (group) -> SKTileGroup in
            _ = group.rules.map({ (rule) -> SKTileGroupRule in
                _ = rule.tileDefinitions.map({ (def) -> SKTileDefinition in
                    _ = def.textures.map({ (texture) -> SKTexture in
                        texture.pixelate()
                        return texture
                    })
                    return def
                })
                return rule
            })
            return group
        }

        for child in children {
            if let map = child as? SKTileMapNode {
                map.pixelate()
            }
        }
    }

    var items: SKTileMapNode {
        guard let items = childNode(withName: "Items") as? SKTileMapNode else { fatalError("Missing Items") }
        return items
    }

    var shadows: SKTileMapNode {
        guard let shadows = childNode(withName: "Shadows") as? SKTileMapNode else { fatalError("Missing Shadows") }
        return shadows
    }

    var grass: SKTileMapNode {
        guard let grass = childNode(withName: "Grass") as? SKTileMapNode else { fatalError("Missing Grass") }
        return grass
    }

    var sfx: SKTileMapNode {
        guard let sfx = childNode(withName: "sfx") as? SKTileMapNode else { fatalError("Missing sfx") }
        return sfx
    }

    func mapPosition(fromLocation: MapLocation) -> CGPoint {
        let center = centerOfTile(atColumn: fromLocation.x, row: fromLocation.y)
        return center
    }

    func mapLocation(fromPosition: CGPoint) -> MapLocation {
        let row = tileRowIndex(fromPosition: fromPosition)
        let column = tileColumnIndex(fromPosition: fromPosition)
        return MapLocation(x: column, y: row)
    }

    var corridors: [MapLocation] {
        return locations.filter { isCorridor($0) }
    }

    func isCorridor(_ loc: MapLocation) -> Bool {
        return tileDefinitions(location: loc).isWalkable && numberOfAdjacentWalkables(loc) == 1 && numberOfAdjacentItems(loc) == 0
    }

    func numberOfAdjacentItems(_ loc: MapLocation) -> Int {
        var count = 0
        if items.tileDefinition(location: .init(x: loc.x + 1, y: loc.y)) != nil {
            count += 1
        }
        if items.tileDefinition(location: .init(x: loc.x - 1, y: loc.y)) != nil {
            count += 1
        }
        if items.tileDefinition(location: .init(x: loc.x, y: loc.y + 1)) != nil {
            count += 1
        }
        if items.tileDefinition(location: .init(x: loc.x, y: loc.y - 1)) != nil {
            count += 1
        }
        return count
    }

    func numberOfAdjacentWalkables(_ loc: MapLocation) -> Int {
        var count = 0
        if tileDefinitions(location: .init(x: loc.x + 1, y: loc.y)).isWalkable {
            count += 1
        }
        if tileDefinitions(location: .init(x: loc.x - 1, y: loc.y)).isWalkable {
            count += 1
        }
        if tileDefinitions(location: .init(x: loc.x, y: loc.y + 1)).isWalkable {
            count += 1
        }
        if tileDefinitions(location: .init(x: loc.x, y: loc.y - 1)).isWalkable {
            count += 1
        }
        return count
    }

    func numberOfCornerWalkables(_ loc: MapLocation) -> Int {
        var count = 0
        if tileDefinitions(location: .init(x: loc.x + 1, y: loc.y + 1)).isWalkable {
            count += 1
        }
        if tileDefinitions(location: .init(x: loc.x + 1, y: loc.y - 1)).isWalkable {
            count += 1
        }
        if tileDefinitions(location: .init(x: loc.x - 1, y: loc.y + 1)).isWalkable {
            count += 1
        }
        if tileDefinitions(location: .init(x: loc.x - 1, y: loc.y - 1)).isWalkable {
            count += 1
        }
        return count
    }

    func tileDefinition(position: CGPoint) -> SKTileDefinition? {
        let loc = mapLocation(fromPosition: position)
        return tileDefinition(atColumn: loc.x, row: loc.y)
    }

    func tileDefinitions(position: CGPoint) -> [SKTileDefinition] {
        let loc = mapLocation(fromPosition: position)
        return tileDefinitions(location: loc)
    }

    func tileDefinitions(location: MapLocation) -> [SKTileDefinition] {
        var defs = [SKTileDefinition]()
        if let tile = tileDefinition(atColumn: location.x, row: location.y) {
            defs.append(tile)
        }
        for child in children {
            if let map = child as? SKTileMapNode {
                if let tile = map.tileDefinition(atColumn: location.x, row: location.y) {
                    defs.append(tile)
                }
            }
        }
        return defs
    }

    func tileDefinition(location: MapLocation) -> SKTileDefinition? {
        return tileDefinition(atColumn: location.x, row: location.y)
    }
}

extension Array where Element: SKTileDefinition {
    var isWalkable: Bool {
        return !isWall && count > 0
    }

    var isStairsDown: Bool {
        return filter { $0.isStairsDown }.count > 0
    }

    var isChestClosed: Bool {
        return filter { $0.isChestClosed }.count > 0
    }

    var isHorz: Bool {
        return filter { $0.isHorz }.count > 0
    }

    var isWall: Bool {
        return filter { $0.isWall }.count > 0
    }

    var isHole: Bool {
        return filter { $0.isHole }.count > 0
    }

    var isSwitch: Bool {
        return filter { $0.isSwitch }.count > 0
    }

    var switchOn: Bool {
        return filter { $0.switchOn }.count > 0
    }
}

extension SKTileDefinition {
    var isWalkable: Bool {
        return !isWall && !isSwitch
    }

    var isStairsDown: Bool {
        return userData?["stairs_down"] as? Bool ?? false
    }

    var isChestClosed: Bool {
        return userData?["isChestClosed"] as? Bool ?? false
    }

    var isHorz: Bool {
        return userData?["isHorz"] as? Bool ?? false
    }

    var isWall: Bool {
        return userData?["isWall"] as? Bool ?? false
    }

    var isHole: Bool {
        return userData?["isHole"] as? Bool ?? false
    }

    var isSwitch: Bool {
        return userData?["isSwitch"] as? Bool ?? false
    }

    var switchOn: Bool {
        return userData?["switchOn"] as? Bool ?? false
    }
}

extension CGSize {
    static func *(lhs: CGSize, rhs: MapLocation) -> CGSize {
        return CGSize(width: lhs.width * CGFloat(rhs.x), height: lhs.height * CGFloat(rhs.y))
    }
}
