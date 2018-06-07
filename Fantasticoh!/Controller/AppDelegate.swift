//
//  AppDelegate.swift
//  Fantasticoh!
//
//  Created by Shubham on 7/27/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import UserNotifications
import Firebase
import CoreSpotlight
import MobileCoreServices
import SwiftyJSON
import GoogleMobileAds



//import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //com.vstarlabs.bb
    var window: UIWindow?
    var welcomePopup = true
    var storyboard : UIStoryboard?;
    var launchedFromPushNotification = false
    var deviceToken: String = ""
    var pushData : PushPayLoad!
    
    /// Saved shortcut item used as a result of an app launch, used later when app is activated.
    
    var launchedShortcutItem: AnyObject?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       // GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                 //   withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
        // nitin
        //SDImageCache.shared().clearMemory()
        //SDImageCache.shared().clearDisk()
        SDImageCache.shared().maxMemoryCountLimit = 100
        //SDWebImageManager.shared().imageDownloader?.maxConcurrentDownloads = 10

        //SDImageCache.shared().maxCacheAge = 5
         SQLiteSportLightObjectManager.createTable()
        self.deactivelocalNotificaiton()
        
        // If a shortcut was launched, display its information and take the appropriate action
        if #available(iOS 9.0, *) {
            self.createDynamicShortcutItems()
            if let launchOptions = launchOptions {
                if let shortcutItem = launchOptions[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
                    
                    self.launchedShortcutItem = shortcutItem
                }
            }
        }
        
        //Note :: Configure Google
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        if configureError != nil {
            print("We have an error! : \(String(describing: configureError)) ")
        }
        
        
        self.storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if CommonFunctions.checkLogin() {
            CommonFunctions.checkUserSession()
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
            vc.home3DTouchState = Home3DTouchState.Home
            let navi = UINavigationController(rootViewController: vc)
            navi.navigationBar.isHidden = true
            self.window?.rootViewController = navi
        } else {
            let getStartedVC = self.storyboard?.instantiateViewController(withIdentifier:"GetStartedVC") as! GetStartedVC
            let vc = UINavigationController(rootViewController: getStartedVC)
            vc.navigationBar.isHidden = true
            self.window?.rootViewController = vc
        }
        
        
        // Register PushNotification
        if application.isRegisteredForRemoteNotifications {
            self.registerForRemonteNotification()
        }
        
        //Note :: Configure facebook
        _ = FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Use Firebase library to configure APIs
        FIRApp.configure()
        FIRMessaging.messaging().remoteMessageDelegate = self
        
        if #available(iOS 9.0, *) {
            
            if  UserDefaults.standard.value(forKey:  NSUserDefaultKeys.spotLightSyncDate) == nil {
              //  self.removeAllSearchItem()
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.statusBarHeightChange),
            name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame,
            object: nil)
        
        SKCache.sharedCache.imageCache = CustomImageCache()
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        SpotLightSearchHelper.sharedInstance.getSpotLightList()
        
        if UserDefaults.standard.value(forKey:  NSUserDefaultKeys.clearNotificationData) == nil {
            UserDefaults.standard.removeObject(forKey: NSUserDefaultKeys.lastNotificationDate)
            UserDefaults.standard.removeObject(forKey: NSUserDefaultKeys.lastNotificationCount)
            UserDefaults.standard.set("Done", forKey: NSUserDefaultKeys.clearNotificationData)
            if #available(iOS 10.0, *)  {
                let center = UNUserNotificationCenter.current()
                 center.removeAllPendingNotificationRequests()
            }
        }
        
        //Note :: Configure Fabric
        Fabric.with([Crashlytics.self])
        
        
        
        return true
    }
    
    func statusBarHeightChange() {
        
        CommonFunctions.delay(delay: 0.2) {
            if let navigationBar = self.window?.rootViewController as? UINavigationController {
                if let vc = navigationBar.viewControllers.first as? TabBarVC {
                    print("success")
                    vc.statusBarHeightChange()
                }
                
            }
        }
    }
    
    func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.deactivelocalNotificaiton() // nitin
        self.activelocalNotificaiton()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        guard  CommonFunctions.checkLogin() else { return }
        WebServiceController.loginSession() { (status, msg, data) in
            print_debug(object: data)
            print_debug(object: msg)
        }
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        CommonFunctions.delay(delay: 0.2) {
            if let navigationBar = self.window?.rootViewController as? UINavigationController {
                if let vc = navigationBar.viewControllers.first as? TabBarVC {
                    print("success")
                    vc.statusBarHeightChange()
                }
                
            }
        }
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if #available(iOS 9.0, *) {
            guard let shortcut = self.launchedShortcutItem as? UIApplicationShortcutItem else { return }
            _ = self.handleShortCutItem(shortcutItem: shortcut)
        }
        self.launchedShortcutItem = nil
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.deactivelocalNotificaiton() // nitin
        self.activelocalNotificaiton()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        /*
         //Note :: Facebook logout
         let loginManager: FBSDKLoginManager = FBSDKLoginManager()
         loginManager.logOut()
         
         //Note :: Google logout
         GIDSignIn.sharedInstance().signOut()
         */
        //self.saveContext()
        
        // nitin
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
        
        
        
        // self.saveContext()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if (url.scheme == "fb1743818985846058")
        {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
        }else if (url.scheme == "fantasticoh")
        {
            guard let id = url.absoluteString.components(separatedBy: "=").last, !id.isEmpty else {return false}
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
            vc.home3DTouchState = Home3DTouchState.Home
            
            
            if url.absoluteString.contains("beep?id="){
                CommonFunctions.delay(delay: 2.0, closure: {
                    vc.showBeepdetail(beepId: id)
                })
            }else if url.absoluteString.contains("channel?id="){
                CommonFunctions.delay(delay: 2.0, closure: {
                    vc.showChannelDetails(channelID: id)
                })
                
            }else if url.absoluteString.contains("user?id="){
                CommonFunctions.delay(delay: 2.0, closure: {
                    vc.showUserProfileDetails(userId: id)
                })
                
            }else if url.absoluteString.contains("search?q="){
                CommonFunctions.delay(delay: 2.0, closure: {
                    vc.showSearchContentDetails(searchText: id)
                })
                
            }else if url.absoluteString.contains("search/channels?q="){
                CommonFunctions.delay(delay: 2.0, closure: {
                    vc.showSearchChannelDetails(searchText: id)
                })
            }
            self.window?.rootViewController = vc
            
        } else {
            return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        return true
    }
    
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
        vc.home3DTouchState = Home3DTouchState.Home
        self.window?.rootViewController = vc
        vc.restoreUserActivityState(userActivity)
        
        if #available(iOS 9.0, *) {
            if userActivity.activityType == CSSearchableItemActionType {
                print(userActivity.userInfo ?? "")
                
                CommonFunctions.delay(delay: 2.0, closure: {
                    if var id =  userActivity.userInfo?["kCSSearchableItemActivityIdentifier"] as? String{
                        id = id.replace(string: "Optional(", replacement: "")
                        id = id.replace(string: ")", replacement: "")
                        id = id.replace(string: "\"", replacement: "")
                        print(id)
                        
                        vc.showChannelDetails(channelID: id)
                        
                    }
                })
            }
        }
        
        
        
        //        let vc = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
        //        vc.home3DTouchState = Home3DTouchState.Explore
        //        self.window?.rootViewController = vc
        //vc.restoreUserActivityState(userActivity)
        return true
    }
    
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "AppInventiv.Fantasticoh_" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Fantasticoh_", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}

// MARK: Remonte Notification Method implementation
extension AppDelegate {
    
    func registerForRemonteNotification()  {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            // Fallback on earlier versions
            let settings = UIUserNotificationSettings(types: [UIUserNotificationType.sound,UIUserNotificationType.alert,UIUserNotificationType.badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print_debug(object: deviceTokenString)
        
        print("deviceTokenString:", deviceTokenString)
        self.deviceToken = "\(deviceTokenString)"
        
        print_debug(object: self.deviceToken)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: FIRInstanceIDAPNSTokenType.prod)
        guard  CommonFunctions.checkLogin() else { return }
        self.updatePushToken()
    }
    
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        CommonFunctions.delay(delay: 10, closure: {
            // CommonFunctions.showInfoAlert(title: "", msg: "didReceiveRemoteNotification")
        })
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        //TODO : Save data using PushPayLoad
        self.launchedFromPushNotification = true
        CommonFunctions.delay(delay: 10, closure: {
            //CommonFunctions.showInfoAlert(title: "", msg: "UIBackgroundFetchResult")
        })
        
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
    }
    
    func updatePushToken() {
        
        //        "apnsToken": true,
        //        "gcmToken": false,
        //        "token": "ABC009ABC009ABC009ABC009ABC009"
        
        guard let userId = CurrentUser.userId else { return }
        var url = WS_UserURL + "/\(userId)"
        url.append("/apppushtokens")
        
        let param: [String : AnyObject] = ["apnsToken" : true as AnyObject, "gcmToken" : true as AnyObject, "token" : self.deviceToken as AnyObject]
        print_debug(object: url)
        
        WebServiceController.updatePushToken(url: url, parameters: param) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            if sucess {
                print_debug(object: "apppushtokens sucessfull.")
            } else {
                print_debug(object: "apppushtokens fail")
            }
        }
    }
    
    
    struct PushPayLoad {
        
        let push_type : String!
        
        init(withPayLoad : [String : AnyObject]) {
            
            self.push_type = withPayLoad["push_type"] as? String ?? ""
        }
        
    }
    
    // nitin
    // set two day local notification
    func activelocalNotificaiton() {
        
        var date = NSDate()
        var loopCount = 64
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests(completionHandler: { (array) in
                loopCount = 2 - array.count
                UserDefaults.standard.set("\(array.count)", forKey: NSUserDefaultKeys.lastNotificationCount)
            })
            if let lastNotificationCount = UserDefaults.standard.value(forKey:  NSUserDefaultKeys.lastNotificationCount) as? String {
                loopCount = 64 - (Int(lastNotificationCount) ?? 0)
            }
        }
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        if let lastNotificationDate = UserDefaults.standard.value(forKey:  NSUserDefaultKeys.lastNotificationDate) as? String {
            print(lastNotificationDate)
            
            let dateFormat = DateFormatter()
            dateFormat.timeZone = TimeZone.current
            dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
            
            if  let preConvertedDate = dateFormat.date(from: lastNotificationDate) {
                print(Date().daysFrom(date: preConvertedDate))
                print(Date().hoursFrom(date: preConvertedDate))
                print(Date().minutesFrom(date: preConvertedDate))
                
                if Date().daysFrom(date: preConvertedDate) >= 0 &&  Date().hoursFrom(date: preConvertedDate) >= 0 && Date().minutesFrom(date: preConvertedDate) >= 0 {
                    
                    date = preConvertedDate as NSDate
                    if Date().daysFrom(date: preConvertedDate) >= 3 {
                        date = NSDate()
                    }
                    
                }
                
                
            }
        }
        
        
        
        
        if #available(iOS 10.0, *) {
            var dateFire : Date? = nil
            for _ in 0...loopCount {
                
                if dateFire != nil {
                    dateFire   = dateFire?.addingTimeInterval((24*60*60))  //((24*60*60)*3)   //((1*60*60)*2)
                } else {
                    dateFire   = date.addingTimeInterval((24*60*60)) as Date //   ((24*60*60)*3)  as Date  //((1*60*60)*2) as Date
                }
                
                var fireComponents=calendar.components([ .hour, .minute,.day,.month,.year], from:dateFire as! Date)
                dateFire = (calendar.date(from: fireComponents)! as NSDate) as Date
                
                fireComponents.hour = 18
                fireComponents.minute = 0
                let dateFormat = DateFormatter()
                dateFormat.timeZone = TimeZone.current
                dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                print(dateFire)
                print(dateFormat.string(from: dateFire!))
                UserDefaults.standard.set("\(dateFormat.string(from: dateFire!))", forKey: NSUserDefaultKeys.lastNotificationDate)
                
                
                let center = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent()
                content.body = CommonTexts.WeMissYouOnFantasticoh
                content.sound = UNNotificationSound.default()
                
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: fireComponents, repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
                
                //let postTime = Date()
                
            }
            
        } else {
            var dateFire = NSDate().addingTimeInterval((24*60*60))//(1 day time * days)
            //        var dateFire=NSDate().addingTimeInterval((1*60)*1)//(1 day time * days)
            
            var fireComponents=calendar.components([ .hour, .minute,.day], from:dateFire as Date)
            
            fireComponents.hour = 18
            fireComponents.minute = 0
            
            dateFire = calendar.date(from: fireComponents)! as NSDate
            
            let notification = UILocalNotification()
            notification.fireDate   = dateFire as Date
            //        notification.fireDate   = NSDate(timeIntervalSinceNow: (60*60*24))
            notification.repeatInterval = .day
            notification.alertBody = CommonTexts.WeMissYouOnFantasticoh
            //notification.alertAction = "be awesome!"
            notification.soundName = UILocalNotificationDefaultSoundName
            APP_DELEGATE.scheduleLocalNotification(notification)
        }
        
        let array =  APP_DELEGATE.scheduledLocalNotifications ?? []
        
        for obj in array {
            print(obj.fireDate ?? "")
        }
        
        guard let settings = APP_DELEGATE.currentUserNotificationSettings else { return }
        
        if settings.types == .none {
            //let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .Alert)
            //ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            //self.window?.rootViewController?.present(ac, animated: true, completion: nil)
            return
        }
        
        
        
    }
    
    func  deactivelocalNotificaiton() {
        //return
        // guard APP_DELEGATE.scheduledLocalNotifications != nil else { return }
        APP_DELEGATE.cancelAllLocalNotifications()
        if #available(iOS 10.0, *)  {
            let center = UNUserNotificationCenter.current()
            center.removeAllDeliveredNotifications() // To remove all delivered notifications
            // center.removeAllPendingNotificationRequests()
        } else {
            // Fallback on earlier versions
        }
        
        
        
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        guard UIApplication.currentVC.isMovie else {
            application.isStatusBarHidden = false
            return application.supportedInterfaceOrientations(for: window)
        }
        return UIInterfaceOrientationMask.all
    }
}


// MARK: 3D Home menu
@available(iOS 9.0, *)
extension AppDelegate {
    
    //1. Search Channel
    //2. Go to Feed
    //3. Share Fantasticoh
    
    enum ShortcutIdentifier: String {
        case SearchChannel
        case GoToFeed
        case Share
        // MARK: Initializers
        
        init?(fullType: String) {
            guard let last = fullType.components(separatedBy: (".")).last else { return nil }
            
            self.init(rawValue: last)
        }
        
        // MARK: Properties
        
        var type: String {
            return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
        }
    }
    
    
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        
        guard let shortCutType = shortcutItem.type as String? else { return false }
        
        switch (shortCutType) {
        case ShortcutIdentifier.SearchChannel.type:
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
            vc.home3DTouchState = Home3DTouchState.Explore
            self.window?.rootViewController = vc
            handled = true
            break
            
        case ShortcutIdentifier.GoToFeed.type:
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
            vc.home3DTouchState = Home3DTouchState.Home
            self.window?.rootViewController = vc
            handled = true
            break
            
        case ShortcutIdentifier.Share.type:
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
            vc.home3DTouchState = Home3DTouchState.Home
            //self.window?.rootViewController = vc
            self.displayShareSheet(shareContent: "https://www.fantasticoh.com")
            handled = true
            break
            /*
             case ShortcutIdentifier.ShareApp.type:
             break
             //self.window?.rootViewController = CommonFunctions.showAlert("Share App", message: "Share this app", btnLbl: "OK")
             //self.displayShareSheet("www.fantasticoh.com")
             handled = true
             break
             */
        default:
            break
        }
        
        return handled
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(self.handleShortCutItem(shortcutItem: shortcutItem))
    }
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void){
        completionHandler(self.handleShortCutItem(shortcutItem: shortcutItem))
    }
    
    func createDynamicShortcutItems() {
        
        //let shortcutItemNumbaOne = UIApplicationShortcutItem(type: .Release, localizedTitle: "Release the Kraken", localizedSubtitle: "Wreak havoc on your enemies.", icon: UIApplicationShortcutIcon(templateImageName: "KrakenDevIcon"), userInfo: nil)
        
        // UIApplicationShortcutItem *item1 = [[UIApplicationShortcutItem alloc]initWithType:@"Item 1" localizedTitle:@"Item 1"];
        let search = UIMutableApplicationShortcutItem(type: Bundle.main.bundleIdentifier! + ".SearchChannel", localizedTitle: "Search Fantasticoh!", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.search), userInfo: nil)
        
        // let yourNewsFeed = UIMutableApplicationShortcutItem(type: Bundle.main.bundleIdentifier! + ".NewsFeed", localizedTitle: "Your News Feed", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.search), userInfo: nil)
        
        
        let share = UIMutableApplicationShortcutItem(type: Bundle.main.bundleIdentifier! + ".Share", localizedTitle: "Share Fantasticoh!", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.share), userInfo: nil)
        
        
        
        
        
        var gotoFeed: UIMutableApplicationShortcutItem!
        
        if #available(iOS 9.1, *) {
            
            gotoFeed = UIMutableApplicationShortcutItem(type: Bundle.main.bundleIdentifier! + ".GoToFeed", localizedTitle: "Your News Feed", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.home), userInfo: nil)
        } else {
            gotoFeed  = UIMutableApplicationShortcutItem(type: Bundle.main.bundleIdentifier! + ".GoToFeed", localizedTitle: "Your News Feed", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.compose), userInfo: nil)
        }
        
        //let shareApp = UIMutableApplicationShortcutItem(type: NSBundle.mainBundle().bundleIdentifier! + ".ShareApp", localizedTitle: "Share Application", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.Share), userInfo: nil)
        
        APP_DELEGATE.shortcutItems = [search, gotoFeed, share]
        
        
        
    }
    
    private func displayShareSheet(shareContent: String) {
        
        let activityVC = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            
            if !success{
                print("cancelled")
                return
            } else {
                print_debug(object: shareContent)
            }
        }
        
        
        
        self.window?.rootViewController?.present(activityVC, animated: true, completion: nil)
        
        
        //UIApplication.sharedApplication().keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        
    }
    
    
    func setSpotLightSearch(searchArray : [SpotLight]) {
        
        DispatchQueue.global(qos: .background).async {
            var arrayOfObbjet = [SpotLight]()
            
            for obj in searchArray {
                
                
                
                
                
                if let result = SQLiteSportLightObjectManager.getSpotLight(spotLightId: obj.channelId), result == false {
                    let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                    attributeSet.title = obj.name
                    attributeSet.contentDescription = obj.description
                    attributeSet.artist = obj.name
                    self.setSearchObject(obj: obj, attributeSet: attributeSet)
                    arrayOfObbjet.append(obj)
                }
                
                
            }
            var counter = 0
            for obj in arrayOfObbjet {
                
                
                if !obj.imageUrl.isEmpty {
                    self.getImageFromURL(fileURL: obj.imageUrl, completionBlock: { [weak self] (status, data) in
                        if let imageData = data {
                            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                            attributeSet.title = obj.name
                            attributeSet.contentDescription = obj.description
                            attributeSet.artist = obj.name
                            attributeSet.thumbnailData = imageData
                            
                            let valueSpotlight = SportLightObject(withData: JSON(JSONDictionary()))
                            valueSpotlight.name = obj.name
                            valueSpotlight.decs = obj.description
                            valueSpotlight.id =  obj.channelId
                            valueSpotlight.url = obj.imageUrl
                            valueSpotlight.status = false
                            
                            valueSpotlight.status = true
                            self?.setSearchObject(obj: obj, attributeSet: attributeSet)
                            SQLiteSportLightObjectManager.insertSportLight(valueSpotlight, obj.channelId)
                            print("insert")
                            counter += 1
                            if counter == arrayOfObbjet.count {
                                print("loop complete")
                                self?.getSpotLightNextPageData()
                            }
                        }
                    })
                } else {
                    counter += 1
                    if counter == arrayOfObbjet.count {
                        print("loop complete")
                        self.getSpotLightNextPageData()
                    }
                }
            }
            
            if arrayOfObbjet.count == 0 {
                print("loop complete")
                self.getSpotLightNextPageData()
            }
            
        }
        
    }
    
    
    func getSpotLightNextPageData() {
       SpotLightSearchHelper.sharedInstance.getSpotLightList()
    }
    
    
    func getImageFromURL( fileURL : String,completionBlock: @escaping spotLightClosure )
    {
        URLSession.shared.dataTask(with: NSURL(string: fileURL)! as URL, completionHandler: { [weak self] (data, response, error) -> Void in
            guard  self != nil else {return}
            if error == nil {
                completionBlock(true,data)
            } else {
                completionBlock(false,nil)
            }
            
        }).resume()
        
    }
    
    func setSearchObject(obj : SpotLight,attributeSet: CSSearchableItemAttributeSet) {
        let item = CSSearchableItem(uniqueIdentifier: "\(obj.channelId)", domainIdentifier: Bundle.main.bundleIdentifier ?? "bb.vstarlabs.com", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if error != nil {
                print_debug(object:"Indexing error: \(String(describing: error?.localizedDescription))")
            } else {
                print_debug(object:"Search item successfully indexed!")
                print_debug(object:"\(obj.name)")
            }
        }
    }
    //    func addSpotLightObject(obj : SpotLight, spotLightImage : UIImage?) {
    //        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
    //        attributeSet.title = obj.name
    //        attributeSet.contentDescription = obj.description
    //        attributeSet.artist = obj.name
    //
    //        if let image = spotLightImage {
    //
    //        }
    //
    //        print(obj.channelId)
    //        let item = CSSearchableItem(uniqueIdentifier: "\(obj.channelId)", domainIdentifier: "bb.vstarlabs.com", attributeSet: attributeSet)
    //        CSSearchableIndex.default().indexSearchableItems([item]) { error in
    //            if let error = error {
    //                print("Indexing error: \(error.localizedDescription)")
    //            } else {
    //                print("Search item successfully indexed!")
    //            }
    //        }
    //    }
    
    func removeAllSearchItem() {
        CSSearchableIndex.default().deleteAllSearchableItems { (error) in
            if error == nil {
                print_debug(object: "searchItem Remove SuccessFully")
            } else {
                print_debug(object: "searchItem failed")
                print_debug(object: error)
            }
        }
        
        let identifier =  Bundle.main.bundleIdentifier ?? "bb.vstarlabs.com"
        
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [identifier]) { (error) in
            if error == nil {
                print_debug(object: "searchItem Remove SuccessFully")
            } else {
                print_debug(object: "searchItem failed")
                print_debug(object: error)
            }
        }
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        if userActivity.activityType == CSSearchableItemActionType {
            
        }
        
        return true
    }
    
}

extension UIApplication {
    struct currentVC {
        static var isMovie: Bool {
            guard let presentedViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController else { return false }
            
            let className = String(describing: type(of: presentedViewController))
            
            return ["MPInlineVideoFullscreenViewController",
                    "MPMoviePlayerViewController",
                    "AVFullScreenViewController"].contains(className)
        }
    }
}




extension AppDelegate : FIRMessagingDelegate {
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
    // [START refresh_token]
    func messaging(_ messaging: FIRMessaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: FIRMessaging, didReceive remoteMessage: FIRMessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

