//
//  JSONLoader.swift
//  Rune
//
//  Created by james bouker on 9/19/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import Foundation

class JSONLoader {

    class func createMap<T>(resource: String, key: (T) -> String) -> [String: T] where T: Codable {
        let jsonDecoder = JSONDecoder()
        let data = JSONLoader.data(resource)
        guard let objects = try? jsonDecoder.decode([T].self, from: data) else {
            fatalError("Could not parse objects: \(T.self)")
        }

        var map = [String: T]()
        for object in objects {
            let k = key(object)
            map[k] = object
        }
        return map
    }

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
