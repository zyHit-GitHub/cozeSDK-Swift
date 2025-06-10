//
//  AppDelegate.swift
//  CozeSDKDemo
//
//  Created by subs on 2025/4/30.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        CozeSDK.shared.initialize(token: APIConfig.accessToken, botId: APIConfig.botId,baseURL: APIConfig.baseURL)
        
       
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = ViewController()
        let nav = UINavigationController(rootViewController: rootVC)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window

        return true
        
    }



}

