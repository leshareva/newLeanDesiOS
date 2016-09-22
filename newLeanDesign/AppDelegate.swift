//
//  AppDelegate.swift
//  newLeanDesign
//
//  Created by Sladkikh Alexey on 9/22/16.
//  Copyright © 2016 LeshaReva. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import Fabric
import DigitsKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.makeKeyAndVisible()
        
        window?.rootViewController = UINavigationController(rootViewController: TaskViewController())
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        UINavigationBar.appearance().barTintColor = UIColor(r: 48, g: 140, b: 229)
        application.statusBarStyle = .LightContent
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tokenRefreshNotification:", name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let notificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        
        FIRApp.configure()
        Fabric.with([Digits.self])
        
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)
        
        
        
        
        // Override point for customization after application launch.
        return true
    }
    
    // Handle refresh notification token
    func tokenRefreshNotification(notification: NSNotification) {
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("InstanceID token: \(refreshedToken)")
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        if (refreshedToken != nil)
        {
            connectToFcm()
            
            FIRMessaging.messaging().subscribeToTopic("/topics/topic")
        }
        
    }
    
    // Connect to FCM
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    // Application entered in background
    func applicationDidEnterBackground(application: UIApplication)
    {
                    FIRMessaging.messaging().disconnect()
                    print("Disconnected from FCM.")
        
        let refreshedToken = FIRInstanceID.instanceID().token()
         print("InstanceID token: \(refreshedToken)")
        if (refreshedToken != nil)
        {
            connectToFcm()
            
            FIRMessaging.messaging().subscribeToTopic("/topics/topic")
           
        }
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    // Application entered in foreground
    func applicationDidBecomeActive(application: UIApplication)
    {
        connectToFcm()
        
        application.applicationIconBadgeNumber = 0;
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("MessageID: \(userInfo["gcm.message_id"])")
        print("%@", userInfo)
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("InstanceID token: \(refreshedToken)")
        
    }
    
    


}

