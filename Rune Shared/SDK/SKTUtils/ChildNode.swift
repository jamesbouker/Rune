//
//  ChildNode.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/29/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

protocol ChildNode {
    func didMoveToScene(scene: GameScene)
}

extension GameScene {
    func notifyChildrenOfMove() {
        enumerateChildNodes(withName: "//*") { node, _ in
            if let child = node as? Player {
                child.didMoveToScene(scene: self)
            }
        }
    }
}
