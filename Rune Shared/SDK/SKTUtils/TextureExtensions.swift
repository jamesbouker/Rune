//
//  TextureExtensions.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/31/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

class TextureCache {
    static let shared = TextureCache()
    private let cache = NSCache<NSString, SKTexture>()
    let atlas = SKTextureAtlas(named: "Sprites")

    private init() {}

    fileprivate func pixelatedTexture(pixelatedImage: String) -> SKTexture? {
        return TextureCache.shared.cache.object(forKey: pixelatedImage as NSString)
    }

    fileprivate func cacheTexture(_ img: SKTexture, pixelatedImage: String) {
        TextureCache.shared.cache.setObject(img, forKey: pixelatedImage as NSString)
    }
}

extension SKTexture {

    static func pixelatedImage(character: Character, direction: Direction? = nil) -> SKTexture {
        let file = character.rawValue + "_1" + (direction != nil ? "_\(direction!.rawValue)" : "")
        return pixelatedImage(file: file)
    }

    static func pixelatedImage(file: String) -> SKTexture {
        if let cached = TextureCache.shared.pixelatedTexture(pixelatedImage: file) {
            cached.pixelate()
            return cached
        }

        let texture = TextureCache.shared.atlas.textureNamed(file)
        texture.pixelate()

        TextureCache.shared.cacheTexture(texture, pixelatedImage: file)
        return texture
    }

    func pixelate() {
        filteringMode = .nearest
    }
}
