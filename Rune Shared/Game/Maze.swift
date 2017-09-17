//
//  Maze.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/18/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

import SpriteKit

class Maze {
    var walls = [MapLocation]()

    fileprivate var xwide: Int
    fileprivate var yhigh: Int

    fileprivate var field = [[String]]()
    fileprivate var frontier = [Point]()

    init(width: Int, height: Int) {
        xwide = height
        yhigh = width

        var possibleWalls = [[MapLocation]]()
        for _ in 0 ... 10 {
            genMaze()
            possibleWalls.append(walls)
            walls = [MapLocation]()
        }

        let chosenWalls = possibleWalls.sorted { $0.count > $1.count }.first
        walls = chosenWalls!
    }
}

fileprivate typealias Point = (x: Int, y: Int)

fileprivate extension MapLocation {
    var key: String {
        return "\(x),\(y)"
    }
}

fileprivate extension Int {
    static func random(n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
}

fileprivate extension Double {
    static func random() -> Double {
        return Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)
    }
}

private func isCorner(p: Point, width: Int, height: Int) -> Bool {
    if p.x == 0 && p.y == 0 {
        return true
    }
    if p.x == width - 1 && p.y == 0 {
        return true
    }
    if p.x == width - 1 && p.y == height - 1 {
        return true
    }
    if p.x == 0 && p.y == height - 1 {
        return true
    }
    return false
}

fileprivate extension Array where Element == Point {
    func corner(xwide: Int, yhigh: Int) -> Point? {
        let corners = filter { isCorner(p: $0, width: xwide, height: yhigh) }
        return corners.first
    }
}

fileprivate extension Maze {

    func carve(_ p: Point) {
        let x = p.x
        let y = p.y

        var extra = [Point]()
        field[y][x] = "."

        if x > 0 {
            if field[y][x - 1] == "?" {
                field[y][x - 1] = ","
                extra.append((x - 1, y))
            }
        }
        if x < xwide - 1 {
            if field[y][x + 1] == "?" {
                field[y][x + 1] = ","
                extra.append((x + 1, y))
            }
        }
        if y > 0 {
            if field[y - 1][x] == "?" {
                field[y - 1][x] = ","
                extra.append((x, y - 1))
            }
        }
        if y < yhigh - 1 {
            if field[y + 1][x] == "?" {
                field[y + 1][x] = ","
                extra.append((x, y + 1))
            }
        }

        extra.shuffle()
        frontier.append(contentsOf: extra)
    }

    func harden(_ p: Point) {
        field[p.y][p.x] = "#"
    }

    func check(_ p: Point, nodiagonals: Bool = true) -> Bool {

        var edgestate = 0
        let x = p.x
        let y = p.y

        if x > 0 {
            if field[y][x - 1] == "." {
                edgestate += 1
            }
        }
        if x < xwide - 1 {
            if field[y][x + 1] == "." {
                edgestate += 2
            }
        }
        if y > 0 {
            if field[y - 1][x] == "." {
                edgestate += 4
            }
        }
        if y < yhigh - 1 {
            if field[y + 1][x] == "." {
                edgestate += 8
            }
        }

        guard nodiagonals else {
            return [1, 2, 4, 8].index(of: edgestate) != nil
        }

        if edgestate == 1 {
            if x < xwide - 1 {
                if y > 0 {
                    if field[y - 1][x + 1] == "." {
                        return false
                    }
                }
                if y < yhigh - 1 {
                    if field[y + 1][x + 1] == "." {
                        return false
                    }
                }
            }
            return true
        } else if edgestate == 2 {
            if x > 0 {
                if y > 0 {
                    if field[y - 1][x - 1] == "." {
                        return false
                    }
                }
                if y < yhigh - 1 {
                    if field[y + 1][x - 1] == "." {
                        return false
                    }
                }
            }
            return true
        } else if edgestate == 4 {
            if y < yhigh - 1 {
                if x > 0 {
                    if field[y + 1][x - 1] == "." {
                        return false
                    }
                }
                if x < xwide - 1 {
                    if field[y + 1][x + 1] == "." {
                        return false
                    }
                }
            }
            return true
        } else if edgestate == 8 {
            if y > 0 {
                if x > 0 {
                    if field[y - 1][x - 1] == "." {
                        return false
                    }
                }
                if x < xwide - 1 {
                    if field[y - 1][x + 1] == "." {
                        return false
                    }
                }
            }
            return true
        }
        return false
    }

    func genMaze() {

        for _ in 0 ..< yhigh {
            var row = [String]()
            for _ in 0 ..< xwide {
                row.append("?")
            }
            field.append(row)
        }

        let xchoice = Int.random(n: xwide)
        let ychoice = Int.random(n: yhigh)
        carve((xchoice, ychoice))

        while frontier.count > 0 {
            let choice: Point
            if let corner = frontier.corner(xwide: xwide, yhigh: yhigh) {
                choice = corner
            } else {
                let randI = Int.random(n: frontier.count)
                choice = frontier[randI]
            }

            if check(choice) {
                carve(choice)
            } else {
                harden(choice)
            }
            let index = frontier.index { $0 == choice }
            if let index = index {
                frontier.remove(at: index)
            }
        }

        // set unexposed cells to be walls
        for x in 0 ..< xwide {
            for y in 0 ..< yhigh where field[y][x] == "?" {
                field[y][x] = "#"
            }
        }

        // Fix the maze
        var needsFixing = true
        while needsFixing {
            needsFixing = false

            for x in 0 ..< xwide {
                for y in 0 ..< yhigh {
                    if field[y][x] == "." && numberOfAdjacentWalkables(x, y) == 0 {
                        field[y][x] = "#"
                        needsFixing = true
                    }
                }
            }
            needsFixing = false
        }

        // Store the maze
        var j = 1
        for x in 0 ..< xwide {
            var i = 0
            for y in 0 ..< yhigh {
                if field[y][x] == "#" {
                    let loc = MapLocation(x: i, y: xwide - j)
                    walls.append(loc)
                }
                i += 1
            }
            j += 1
        }
    }

    func numberOfAdjacentWalkables(_ x: Int, _ y: Int) -> Int {
        var count = 0
        if x < xwide - 1 {
            if field[y][x + 1] == "." {
                count += 1
            }
        }
        if x > 0 {
            if field[y][x - 1] == "." {
                count += 1
            }
        }
        if y < yhigh - 1 {
            if field[y + 1][x] == "." {
                count += 1
            }
        }
        if y > 0 {
            if field[y - 1][x] == "." {
                count += 1
            }
        }
        return count
    }
}
