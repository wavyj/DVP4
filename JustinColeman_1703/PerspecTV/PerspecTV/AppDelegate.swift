//
//  AppDelegate.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/8/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let consumerID = "i6upsqp6ugslfdqk87z7t1ghxpf9dz"
    let secret = "i2wtk0bfdg4wasxj00gvtq0zh7gytz"
    let apiVersion = "api_version=5"
    let redirectUrl = "com.perspectv.ios://url-callback"
    var currentUser: User!
    var streams: [Channel]!
    var isPhone: Bool!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        streams = [Channel]()
        //Checks current device
        if UIDevice.current.model == "iPhone" || UIDevice.current.model == "iPod"{
            isPhone = true
        }else if UIDevice.current.model == "iPad"{
            isPhone = false
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == "url-callback"{
            //Get auth token
            var temp = url.fragment!
            let splitArray = temp.characters.split(separator: "=").map(String.init)
            let token = splitArray[1].characters.split(separator: "&").map(String.init)
            currentUser = User(authToken: token[0])
            
            //Dismiss UiWebView
            let LVC = self.window?.rootViewController as! LoginViewController
            LVC.webView.removeFromSuperview()
            
            //Get user's data
            LVC.currentUser = self.currentUser
            LVC.getUser()
        }
        return true
    }


}

