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
import Flurry_iOS_SDK


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var taskViewController: TaskViewController?
    var tasks = [Task]()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Flurry.setDebugLogEnabled(true);
        Flurry.startSession("ZXPZJMMTYDFZRBRHW339");
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.makeKeyAndVisible()
        
        window?.rootViewController = UINavigationController(rootViewController: StartViewController())
        
//        var rootView: StartViewController = StartViewController()
//        
//        if let window = self.window{
//            window.rootViewController = rootView
//        }
        
        
        UINavigationBar.appearance().barTintColor = UIColor(r: 0, g: 140, b: 255)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.tokenRefreshNotification(_:)), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        
        
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
        
            connectToFcm()
            
            FIRMessaging.messaging().subscribeToTopic("/topics/topic")
       
        
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Sandbox)
        print("In did register For remote Not with token: \(FIRInstanceID.instanceID().token())")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    // Application entered in foreground
    func applicationDidBecomeActive(application: UIApplication)
    {
        connectToFcm()
        let refreshedToken = FIRInstanceID.instanceID().token()
        if (refreshedToken != nil) {
            if let userId = Digits.sharedInstance().session()?.userID  {
                let clientsReference = FIRDatabase.database().reference().child("user-token").child(userId)
                clientsReference.updateChildValues([refreshedToken!: 1])
            }
        }
        application.applicationIconBadgeNumber = 0;
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    var navController: UINavigationController?
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("MessageID: \(userInfo["gcm.message_id"])")
        print("%@", userInfo)
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("InstanceID token: \(refreshedToken)")

        
        if application.applicationState == UIApplicationState.Active {
            print("App already open")
        } else {
            print("App opened from Notification")
            
            if let taskId = userInfo["gcm.notification.taskId"] as? String {
                print(taskId)
   //             let chatController = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
                
//                let taskViewController = TaskViewController()
//                
//                let dictionary: [String: AnyObject] = ["taskId": taskId]
//                let task = Task()
//                
//                task.setValuesForKeysWithDictionary(dictionary)
//                taskViewController.showChatControllerForUser(task)
            }
            
            
            
        }
        
        
    }
    
    


}

