//
//  AppDelegate.swift
//  Rune iOS
//
//  Created by james bouker on 9/16/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import UIKit
import BuddyBuildSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()
        return true
    }
}
