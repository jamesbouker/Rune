//
//  UserDefaultsExtensions.swift
//  1 Bit Rogue
//
//  Created by james bouker on 9/5/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import Foundation

typealias Storage = UserDefaults
extension UserDefaults {
    private static let kPlayerHealth = "playerHealth"

    static var playerHealth: Int {
        set {
            standard.set(newValue, forKey: UserDefaults.kPlayerHealth)
        } get {
            return standard.value(forKey: UserDefaults.kPlayerHealth) as? Int ?? 2
        }
    }
}
