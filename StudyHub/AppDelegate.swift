    //
    //  AppDelegate.swift
    //  StudyHub
    //
    //  Created by Dan Levy on 11/4/16.
    //  Copyright © 2016 Dan Levy. All rights reserved.
    //
    
    import UIKit
    import CoreData
    import Firebase
    import FBSDKCoreKit
    import FBSDKLoginKit
    import TwitterKit
    import UserNotifications
    import MBProgressHUD
    import Reachability
//    import FirebaseStorageUI
    
    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        var window: UIWindow?
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            self.getThisUser()
            // Firebase
            FirebaseApp.configure()
            self.getUserAuth()
            // Navigation Bar and Status Bar Customization
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.white
            //        navigationBarAppearace.barTintColor = studyHubColor
            navigationBarAppearace.barStyle = .black
            navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            navigationBarAppearace.backItem?.title = "<"
            
            //Page ViewController
            let pageControl = UIPageControl.appearance()
            pageControl.pageIndicatorTintColor = UIColor.lightGray
            pageControl.currentPageIndicatorTintColor = UIColor.black
            pageControl.backgroundColor = UIColor.white
            
            // Notifications
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization( options: authOptions, completionHandler: {_, _ in })
            
            // Facebook
            FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
            
            // Twitter
//            Twitter.sharedInstance().start(withConsumerKey:"CR6q1R4ZKB7Ln5u9WlexJYLkK", consumerSecret:"0ARIYnZGM5hbQid8Ro9Sqs78PKvcjqASbfNcECHGl5FVu4NWPj")
            
            // Initial VC
            if (currentUser != nil) {
                initialVC(storyboardID: "TabBarVC")
            } else {
                initialVC(storyboardID: "SignInVC")
            }
            
            //        initialVC(storyboardID: "authenticationVC")
            
            // Reachability
            networkIsReachable = true
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(notification:)), name: NSNotification.Name.reachabilityChanged, object: reachability)
            do {
                try reachability?.startNotifier()
            } catch {
            }
            return true
        }
        
        func getThisUser() {
            let thisUserRequest: NSFetchRequest<ThisUser> = ThisUser.fetchRequest()
            do {
                let user = try managedObjectContext.fetch(thisUserRequest).first
                if let user = user {
                    thisUser = user
                } else {
                    thisUser = NSEntityDescription.insertNewObject(forEntityName: "ThisUser", into: managedObjectContext) as? ThisUser
                }
            } catch {
                print("Could not get ThisUser object: \(error.localizedDescription)")
            }
        }
        
        func getUserAuth() {
            Auth.auth().addStateDidChangeListener({ (auth, user) in
                currentUser = user
                if (currentUser == nil) {
                    print("***** CURRENT USER WAS LOST")
                    // TODO: Display error to re-sign in user
                } else {
                    self.getUserDetails()
                }
            })
        }
        
        func getUserDetails() {
            let userRef = firestoreRef.collection("users").document(currentUser!.uid)
            userRef.getDocument { (snap, error) in
                if (error == nil && snap!.exists) {
                    for data in snap!.data()! {
                        if (data.key != "signUpTimestamp") {
                           thisUser!.setValue(data.value, forKey: data.key)
                        }
                    }
                    thisUser!.setValue(currentUser!.uid, forKey: "uid")
                    thisUser?.setValue(userRef, forKey: "ref")
                    self.getProfileImage()
                }
            }
//            databaseReference.child("users").child(currentUser!.uid).child("userDetails").observe(.value, with: { (snap) in
//                if (snap.childrenCount > 0) {
//                    self.deleteOldThisUser()
//                    let children = snap.children.allObjects as! [DataSnapshot]
//                    let user = NSEntityDescription.insertNewObject(forEntityName: "ThisUser", into: managedObjectContext) as! ThisUser
//                    for child in children {
//                        user.setValue(child.value as? String, forKey: child.key)
//                    }
//                    user.setValue(currentUser!.uid, forKey: "uid")
//                    thisUser = user
//                    self.getImage(user: user, imageType: "headerImage", numberOfImages: 2)
//                }
//            })
        }
        
//        func deleteOldThisUser() {
//            let thisUserRequest: NSFetchRequest<ThisUser> = ThisUser.fetchRequest()
//            do {
//                let users = try managedObjectContext.fetch(thisUserRequest)
//                if let user = users.first {
//                    managedObjectContext.delete(user)
//                }
//            } catch {
//                print("Could not get ThisUser object: \(error.localizedDescription)")
//            }
//        }
        
        func getProfileImage() {
            storageReference.child("users").child("profilePictures").child(thisUser!.uid! + "profilePicture").getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if (error == nil) {
                    thisUser!.setValue(data! as NSData, forKey: "profileImage")
                }
                
//                if (numberOfImages == 1) {
//                    do {
//                        try managedObjectContext.save()
//                    } catch {
//                        print("GET USER DETAILS CORE DATA ERROR: \(error.localizedDescription)")
//                    }
//                    thisUser = user
//                } else {
//                    self.getImage(user: user, imageType: "profileImage", numberOfImages: 1)
//                }
            })
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
        }
        
        func applicationDidBecomeActive(application: UIApplication) {
            FBSDKAppEvents.activateApp()
        }
        
        func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
            FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
            return true
        }
        
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        }
        
        func initialVC(storyboardID: String) {
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "\(storyboardID)") as UIViewController
            self.window?.makeKeyAndVisible()
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewController
        }
        
        @objc func reachabilityChanged(notification: NSNotification) {
            let reachability = notification.object as! Reachability
            if (reachability.connection != .none) {
                if (networkIsReachable == false) {
                    self.window?.rootViewController?.displayNetworkReconnection()
                }
                networkIsReachable = true
            } else {
                if (networkIsReachable == true) {
                    self.window?.rootViewController?.displayNoNetworkConnection()
                }
                networkIsReachable = false
            }
        }
        
        // MARK: - Core Data stack
        lazy var persistentContainer: NSPersistentContainer = {
            /*
             The persistent container for the application. This implementation
             creates and returns a container, having loaded the store for the
             application to it. This property is optional since there are legitimate
             error conditions that could cause the creation of the store to fail.
             */
            let container = NSPersistentContainer(name: "StudyHub")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        // MARK: - Core Data Saving support
        func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
