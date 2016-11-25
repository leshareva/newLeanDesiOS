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
import Crashlytics



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var taskViewController: TaskViewController?
    var tasks = [Task]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Digits.self, Crashlytics.self])

        
        Flurry.setDebugLogEnabled(true);
        Flurry.startSession("ZXPZJMMTYDFZRBRHW339");
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        window?.rootViewController = UINavigationController(rootViewController: StartViewController())
        
//        var rootView: StartViewController = StartViewController()
//        
//        if let window = self.window{
//            window.rootViewController = rootView
//        }
        
        
        UINavigationBar.appearance().barTintColor = UIColor(r: 0, g: 127, b: 255)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
        UINavigationBar.appearance().tintColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.tokenRefreshNotification(_:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        
        FIRApp.configure()
        Fabric.with([Digits.self])
        
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)
        

        // Override point for customization after application launch.
        return true
    }
    

    
    // Handle refresh notification token
    func tokenRefreshNotification(_ notification: Notification) {
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("InstanceID token: \(refreshedToken)")
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        if (refreshedToken != nil)
        {
            connectToFcm()
            FIRMessaging.messaging().subscribe(toTopic: "/topics/topic")   
        }
        
    }
    
    // Connect to FCM
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    // Application entered in background
    func applicationDidEnterBackground(_ application: UIApplication)
    {
                    FIRMessaging.messaging().disconnect()
                    print("Disconnected from FCM.")
        
            connectToFcm()
            
            FIRMessaging.messaging().subscribe(toTopic: "/topics/topic")
       
        
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
        print("In did register For remote Not with token: \(FIRInstanceID.instanceID().token())")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    // Application entered in foreground
    func applicationDidBecomeActive(_ application: UIApplication)
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

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    var navController: UINavigationController?
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("MessageID: \(userInfo["gcm.message_id"])")
        print("%@", userInfo)
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("InstanceID token: \(refreshedToken)")

        
        if application.applicationState == UIApplicationState.active {
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

