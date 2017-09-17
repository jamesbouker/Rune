//
//  NodeExtensions.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/31/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

enum ActionType: String {
    case moving
    case twoFrame
}

extension SKSpriteNode {
    func runs(_ actions: [SKAction], type: ActionType) {
        run(.sequence(actions), withKey: type.rawValue)
    }

    func run(_ action: SKAction, type: ActionType) {
        run(action, withKey: type.rawValue)
    }

    func move(to: CGPoint, duration: TimeInterval) {
        guard !isMoving else { fatalError("Already moving") }
        runs([.move(to: to, duration: duration), .removeAction(.moving)], type: .moving)
    }

    func removeAction(forType: ActionType) {
        removeAction(forKey: forType.rawValue)
    }

    func action(forType: ActionType) -> SKAction? {
        return action(forKey: forType.rawValue)
    }

    var isMoving: Bool {
        return action(forType: .moving) != nil
    }
}
