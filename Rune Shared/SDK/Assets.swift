//
//  Assets.swift
//  1 Bit Rogue
//
//  Created by james bouker on 9/3/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

enum EnvAtlas: String {
    case brick
    case stone
    case vine
    case sand
}

enum Asset: String {
    case rip
}

extension SKTexture {
    class func fromAsset(_ asset: Asset) -> SKTexture {
        return SKTexture.pixelatedImage(file: asset.rawValue)
    }
}

class Assets {
    class var rip: SKTexture {
        return .fromAsset(.rip)
    }
}
