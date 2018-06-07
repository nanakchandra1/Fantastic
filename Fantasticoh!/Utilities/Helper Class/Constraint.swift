//
//  Constraint.swift
//  Fantasticoh!
//
//  Created by Shubham on 8/2/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation
import UIKit

var FB_AD :Bool = false
let SCREEN_WIDTH        = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT       = UIScreen.main.bounds.size.height
let MAIN_SCREEN_VIEW    = UIApplication.shared.keyWindow?.rootViewController?.view

let SHARED_APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
let APP_DELEGATE        = UIApplication.shared


var PROFILEPLACEHOLDER   = UIImage(named: "user_placeholder")
//var CONTAINERPLACEHOLDER = UIImage(named: "content_placeholder")
//var CHANNELLOGOPLACEHOLDER = UIImage(named: "channel_placeholder")

var CHANNELLOGOPLACEHOLDER = UIImage(named: "AppIconPlaceHolder")
var AppIconPLACEHOLDER = UIImage(named: "AppIconPlaceHolder")
var CONTAINERPLACEHOLDER = UIImage(named: "AppIconPlaceHolder")
var loadingPLACEHOLDER = UIImage(named: "loadingImage")
var transparentPLACEHOLDER = UIImage(named: "grid")



var ALLTAGVCDELEGATE: AllTagVCDelegate!
var IsShowTap = true

weak var TABBARDELEGATE: TabBarDelegate!




//MARK:- Static Keys
//MARK:-
struct  NSUserDefaultKeys {

    static let ISLOGIN          	= "isLoggedIn"
    static let ISNEWUSER            = "isNewUser"
    static let COOKIEADDRESS        = "cookieAddress"
    
    static let USERID               = "id"
    
    static let CREATETIME           = "createTime"
    static let LOGINTIME            = "loginTime"
    static let LOGINIP              = "loginIP"
    
    static let FACEBOOKID       	= "facebookID"
    static let FACEBOOKTOKEN        = "facebookToken"
    static let GOOGLEID         	= "googleID"
    static let GOOGLETOKEN      	= "googleToken"
    static let ISADMIN              = "admin"
    static let CLOSED               = "closed"
    static let VIAUSER              = "viaUser"
    static let VIACODE              = "viaCode"
    static let AVATARID         	= "avatarID"
    static let AVATAREXTURL     	= "avatarExtURL"
    static let HEADERID             = "headerIDs"
    static let NAME             	= "name"
    static let TAGLINE          	= "tagLine"
    static let BIO                  = "bio"
    static let EMAIL                = "email"
    static let LOCATION             = "location"
    static let LOCATIONNAME         = "locationName"
    static let COUNTRY              = "country"
    static let BIRTHYEAR            = "birthYear"
    static let NOTIFICATIONENABLED  = "notificationsEnabled"
    static let NOTIFICATIONCHANNELS = "notificationChannels" // Future user
    static let PUSHTOKENS           = "pushTokens"
    static let COUNTFOLLOWING       = "countFollowing"
    static let COUNTFLAGS           = "countFlags"
    static let PROFESSION             	= "profession"
    
    static let CHANNELSEARCHARRAY   = "channelSearch"
    
    static let PROFILECOUNTRYLIST   = "profileCountryList"
    
    static let FRIENDSLIST          = "friendsList"
    static let SHOWREMOVEPROFILEPIC             	= "showRemoveProfilePic" // nitin
    
    static let spotLightSyncDate   = "spotLightSyncDate"
    static let lastNotificationDate   = "lastNotificationDate"
    static let lastNotificationCount   = "lastNotificationCount"
    static let clearNotificationData   = "clearNotificationData"

}

var isIPhoneSimulator:Bool{
    
    var isSimulator = false
    #if arch(i386) || arch(x86_64)
        //simulator
        isSimulator = true
    #endif
    return isSimulator
}

public func print_debug <T> (object: T) {
    
    // TODO: Comment Next Statement To Deactivate Logs
    if isIPhoneSimulator{
        print(object)
        //        NSLog("\(object)")
    } else {
        print(object)
       // NSLog("\(object)")
    }
    
}
