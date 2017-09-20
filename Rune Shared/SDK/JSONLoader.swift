//
//  JSONLoader.swift
//  Rune
//
//  Created by james bouker on 9/19/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import Foundation

class JSONLoader {
    class func data(_ resource: String) -> Data {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            fatalError("Missing \(resource).json")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(resource).json")
        }
        return data
    }

    class func json(_ resource: String) -> [String: [String: AnyObject]] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            fatalError("Missing \(resource).json")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(resource).json")
        }
        let j = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let json = j as? [String: [String: AnyObject]] else {
            fatalError("Could not create json")
        }
        return json
    }
}
