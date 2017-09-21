//
//  ActionExtensions.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/31/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

extension SKAction {
    class func twoFrameAnim(pixelatedFile: String, direction: String? = nil) -> SKAction {
        let file1 = pixelatedFile + "_1" + (direction != nil ? "_\(direction!)" : "")
        let file2 = pixelatedFile + "_2" + (direction != nil ? "_\(direction!)" : "")
        let frame1 = SKTexture.pixelatedImage(file: file1)
        let frame2 = SKTexture.pixelatedImage(file: file2)
        let anim = SKAction.animate(with: [frame1, frame2], timePerFrame: frameTime)
        return .repeatForever(anim)
    }

    class func removeAction(_ type: ActionType) -> SKAction {
        return SKAction.customAction(withDuration: 0) { node, _ in
            node.removeAction(forKey: type.rawValue)
        }
    }
}
