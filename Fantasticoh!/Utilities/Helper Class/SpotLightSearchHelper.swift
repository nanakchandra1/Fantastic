//
//  SpotLightSearchHelper.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 12/12/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import Foundation

class SpotLightSearchHelper {
    
    static let sharedInstance = SpotLightSearchHelper()
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var fromSpotLight = 0
    var sizeSpotLight = 200
    
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func getSpotLightList() {
        
        DispatchQueue.global(qos: .background).async {
            if self.sizeSpotLight == 0 {
                return
            }
            let url =  WS_SpotLightlList + "/paginated?from=\(self.fromSpotLight)&size=\(self.sizeSpotLight)&onlyLive=true&notClosed=true"

//            WebServiceController.getSpotLightSearchList(url: url) { (success, data) in
//
//                if success {
//                    if #available(iOS 9.0, *) {
//
//                        if let array = data as? [[String : AnyObject]] {
//                            //print_debug(object: array)
//                            var spotLightSearchArray = [SpotLight]()
//                            for obj in array {
//                                if let name = obj["name"] as? String, let desc = obj["desc"] as? String,let channelID = obj["id"] as? String {
//                                    print_debug(object: "&&&&&&&&&&&")
//                                    print_debug(object: name)
//                                    var imageUrl = ""
//
//                                    if let avatarURLLarge = obj["avatarURL"] as? String {
//                                        imageUrl = avatarURLLarge
//                                    }
//
//                                    //                                    imageUrl = "https://storage.googleapis.com/vsl-bb-avatars.vstarlabs.com/e6be496dac504520.jpg"
//
//
//                                    spotLightSearchArray.append(SpotLight(name: name, description: desc, channelId: channelID, imageUrl: imageUrl))
//                                }
//
//                            }
//
//                            SHARED_APP_DELEGATE.setSpotLightSearch(searchArray: spotLightSearchArray)
//                            if array.count > 0 {
//                                self.fromSpotLight = self.fromSpotLight + self.sizeSpotLight
//                                //self.getSpotLightList()
//                            } else {
//                                self.fromSpotLight = 0
//                                self.sizeSpotLight = 0
//                                let postTime = Date()
//                                let dateFormat = DateFormatter()
//                                dateFormat.timeZone = TimeZone(identifier: "UTC")
//                                dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
//
//                                UserDefaults.standard.set("\(dateFormat.string(from: postTime))", forKey: NSUserDefaultKeys.spotLightSyncDate)
//                            }
//
//                        }
//                    } else {
//
//
//                        CommonFunctions.delay(delay: 2.0, closure: {
//                            self.getSpotLightList()
//                        })
//                    }
//                }
//            }
        }
    }
}
