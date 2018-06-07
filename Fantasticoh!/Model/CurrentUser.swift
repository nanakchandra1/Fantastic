//
//  File.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 26/08/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation

class CurrentUser{
    
    static var userId : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.USERID)
    }
    
    static var createTime : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.CREATETIME)
    }
    
    static var loginTime : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.LOGINTIME)
    }
    
    static var loginIP : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.LOGINIP)
    }
    
    static var facebookId : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.FACEBOOKID)
    }
    
    static var facebookToken : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.FACEBOOKTOKEN)
    }
    
    static var googleId : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.GOOGLEID)
    }
    
    static var googleToken : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.GOOGLETOKEN)
    }
    
    static var isAdmin : Bool?{
        return UserDefaults.getBoolVal(key: NSUserDefaultKeys.ISADMIN)
    }
    
    static var closed : Bool?{
        return UserDefaults.getBoolVal(key: NSUserDefaultKeys.CLOSED)
    }
    
    static var viaUser : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.VIAUSER)
    }
    
    static var viaCode : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.VIACODE)
    }
    
    static var avatarID : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.AVATARID)
    }
    
    static var avatarExtURL : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.AVATAREXTURL)
    }
    
    static var headerIDs : [AnyObject]?{
        //return UserDefaults.getStringVal(NSUserDefaultKeys.HEADERID)
        return UserDefaults.getCustomArrayVal(key: NSUserDefaultKeys.HEADERID)
    }
    
    static var notificationsChannels : [AnyObject]?{
        return UserDefaults.getCustomArrayVal(key: NSUserDefaultKeys.NOTIFICATIONCHANNELS)
    }
    
    static var name : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.NAME)
    }
    
    static var tagLine : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.TAGLINE)
    }
    
    static var bio : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.BIO)
    }
    
    static var email : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.EMAIL)
    }
    
    static var location : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.LOCATION)
    }
    
    static var locationName : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.LOCATIONNAME)
    }
    
    static var country : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.COUNTRY)
    }
    
    static var birthYear : Int?{
        return UserDefaults.getIntVal(key: NSUserDefaultKeys.BIRTHYEAR)
    }
    
    static var notificationsEnabled : Bool?{
        return UserDefaults.getBoolVal(key: NSUserDefaultKeys.NOTIFICATIONENABLED)
    }
    static var pushTokens : [String]? {
        if var array = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.PUSHTOKENS) as? [String] {
            if !array.contains(SHARED_APP_DELEGATE.deviceToken) {
                array.append(SHARED_APP_DELEGATE.deviceToken)
            }
            return array
        } else {
           return [SHARED_APP_DELEGATE.deviceToken]
        }
    }
    
    static var countFollowing : Int?{
        return UserDefaults.getIntVal(key: NSUserDefaultKeys.COUNTFOLLOWING)
    }
    
    static var countFlags : Int?{
        return UserDefaults.getIntVal(key: NSUserDefaultKeys.COUNTFLAGS)
    }
    
    static var profession : String?{
        return UserDefaults.getStringVal(key: NSUserDefaultKeys.PROFESSION)
    }
    
    static var showRemoveProfilePic : Bool{
        return UserDefaults.getBoolVal(key: NSUserDefaultKeys.SHOWREMOVEPROFILEPIC) ?? true
    }
    
    
    init(param:[String : AnyObject]) {
    
            /*
         TODO : Remove
        UserDefaults.setStringVal("4a64bd45672f4ab8", forKey: NSUserDefaultKeys.USERID)
        UserDefaults.setStringVal("11s11", forKey: NSUserDefaultKeys.FACEBOOKID)
        UserDefaults.setStringVal("1s11", forKey: NSUserDefaultKeys.FACEBOOKTOKEN)
        UserDefaults.setBoolVal(false, forKey: NSUserDefaultKeys.ISADMIN)
        UserDefaults.setBoolVal(false, forKey: NSUserDefaultKeys.CLOSED)
        UserDefaults.setStringVal("", forKey: NSUserDefaultKeys.VIAUSER)
        UserDefaults.setStringVal("4a64bd", forKey: NSUserDefaultKeys.VIACODE)
        UserDefaults.setStringVal("4a64bd45672f4ab8", forKey: NSUserDefaultKeys.AVATARID)
        UserDefaults.setStringVal("https://yt3.ggpht.com/-1T1SCHCg1FQ/AAAAAAAAAAI/AAAAAAAAAAA/8FY0PMmPr3I/s88-c-k-no-mo-rj-c0xffffff/photo.jpg", forKey: NSUserDefaultKeys.AVATAREXTURL)
        UserDefaults.setStringVal("", forKey: NSUserDefaultKeys.HEADERID)
        UserDefaults.setStringVal("PD", forKey: NSUserDefaultKeys.NAME)
        UserDefaults.setStringVal("", forKey: NSUserDefaultKeys.TAGLINE)
        UserDefaults.setStringVal("Emp", forKey: NSUserDefaultKeys.BIO)
        UserDefaults.setStringVal("pd@gmail.com", forKey: NSUserDefaultKeys.EMAIL)
        UserDefaults.setStringVal("", forKey: NSUserDefaultKeys.LOCATION)
        UserDefaults.setStringVal("", forKey: NSUserDefaultKeys.LOCATIONNAME)
        UserDefaults.setStringVal("in", forKey: NSUserDefaultKeys.COUNTRY)
        UserDefaults.setIntVal("2000", forKey: NSUserDefaultKeys.BIRTHYEAR)
        UserDefaults.setBoolVal(false, forKey: NSUserDefaultKeys.NOTIFICATIONENABLED)
        UserDefaults.setStringVal("", forKey: NSUserDefaultKeys.PUSHTOKENS)
        UserDefaults.setStringVal("", forKey: NSUserDefaultKeys.PUSHTOKENS)
        UserDefaults.setIntVal(0, forKey: NSUserDefaultKeys.COUNTFOLLOWING)
        UserDefaults.setIntVal(0, forKey: NSUserDefaultKeys.COUNTFLAGS)
        UserDefaults.setStringVal("Designner", forKey: NSUserDefaultKeys.PROFESSION)
        UserDefaults.setBoolVal(false, forKey: NSUserDefaultKeys.NOTIFICATIONENABLED)
        */
        
        if let userData = param["user"] as? [String : AnyObject] {
            
            print_debug(object: userData)
            if let user = userData["user"] as? [String : AnyObject] {
            
                if let id = user["id"] as? String {
                    UserDefaults.setStringVal(value: id as AnyObject, forKey: NSUserDefaultKeys.USERID)
                }

                if let createTime = user["createTime"] as? String {
                    UserDefaults.setStringVal(value: createTime as AnyObject, forKey: NSUserDefaultKeys.CREATETIME)
                }
                
                if let loginTime = user["loginTime"] as? String {
                    UserDefaults.setStringVal(value: loginTime as AnyObject, forKey: NSUserDefaultKeys.LOGINTIME)
                }
                
                if let loginIP = user["loginIP"] as? String {
                    UserDefaults.setStringVal(value: loginIP as AnyObject, forKey: NSUserDefaultKeys.LOGINIP)
                }
                
                if let authId = user["authIDs"] as? [String : AnyObject] {
                    
                    if let facebookID = authId["facebookID"] as? String {
                        UserDefaults.setStringVal(value: facebookID as AnyObject, forKey: NSUserDefaultKeys.FACEBOOKID)
                    }
                    
                    if let facebookToken = authId["facebookToken"] as? String {
                        UserDefaults.setStringVal(value: facebookToken as AnyObject, forKey: NSUserDefaultKeys.FACEBOOKTOKEN)
                    }
                    
                    if let googleID = authId["googleID"] as? String {
                        UserDefaults.setStringVal(value: googleID as AnyObject, forKey: NSUserDefaultKeys.GOOGLEID)
                    }
                    
                    if let googleToken = authId["googleToken"] as? String {
                        UserDefaults.setStringVal(value: googleToken as AnyObject, forKey: NSUserDefaultKeys.GOOGLETOKEN)
                    }
                }

                if let admin = user["admin"] as? Bool {
                    UserDefaults.setBoolVal(state: admin, forKey: NSUserDefaultKeys.ISADMIN)
                }
                
                if let closed = user["closed"] as? Bool {
                    UserDefaults.setBoolVal(state: closed, forKey: NSUserDefaultKeys.CLOSED)
                }
                
                if let viaUser = user["viaUser"] as? String {
                    UserDefaults.setStringVal(value: viaUser as AnyObject, forKey: NSUserDefaultKeys.VIAUSER)
                }
                
                if let viaCode = user["viaCode"] as? String {
                    UserDefaults.setStringVal(value: viaCode as AnyObject, forKey: NSUserDefaultKeys.VIACODE)
                }
                
                if let avatarID = user["avatarID"] as? String {
                    UserDefaults.setStringVal(value: avatarID as AnyObject, forKey: NSUserDefaultKeys.AVATARID)
                }
                
                if let headerIDs = user["headerIDs"] as? [AnyObject] {
                    UserDefaults.setCustomArrayVal(value: headerIDs, forKey: NSUserDefaultKeys.HEADERID)
                } else {
                    UserDefaults.setStringVal(value: "" as AnyObject, forKey: NSUserDefaultKeys.HEADERID)
                }
                
                if let notificationChannels = user["notificationChannels"] as? [AnyObject] {
                    UserDefaults.setCustomArrayVal(value: notificationChannels, forKey: NSUserDefaultKeys.NOTIFICATIONCHANNELS)
                } else {
                    UserDefaults.setStringVal(value: "" as AnyObject, forKey: NSUserDefaultKeys.NOTIFICATIONCHANNELS)
                }
                
                if let name = user["name"] as? String {
                    UserDefaults.setStringVal(value: name as AnyObject, forKey: NSUserDefaultKeys.NAME)
                }
                
                if let tagLine = user["tagLine"] as? String {
                    UserDefaults.setStringVal(value: tagLine as AnyObject, forKey: NSUserDefaultKeys.TAGLINE)
                }
                
                if let bio = user["bio"] as? String {
                    UserDefaults.setStringVal(value: bio as AnyObject, forKey: NSUserDefaultKeys.BIO)
                }
                
                if let email = user["email"] as? String {
                    UserDefaults.setStringVal(value: email as AnyObject, forKey: NSUserDefaultKeys.EMAIL)
                }
                
                if let location = user["location"] as? String  {
                    UserDefaults.setStringVal(value: location as AnyObject, forKey: NSUserDefaultKeys.LOCATION)
                } else {
                    UserDefaults.setStringVal(value: "" as AnyObject, forKey: NSUserDefaultKeys.LOCATION)
                }
                
                if let locationName = user["locationName"] as? String {
                    UserDefaults.setStringVal(value: locationName as AnyObject, forKey: NSUserDefaultKeys.LOCATIONNAME)
                }
                
                if let country = user["country"] as? String {
                    UserDefaults.setStringVal(value: country as AnyObject, forKey: NSUserDefaultKeys.COUNTRY)
                }
                
                if let birthYear = user["birthYear"] as? Int {
                    UserDefaults.setIntVal(value: birthYear as AnyObject, forKey: NSUserDefaultKeys.BIRTHYEAR)
                }
                
                if let notificationsEnabled = user["notificationsEnabled"] as? Bool {
                    UserDefaults.setBoolVal(state: notificationsEnabled, forKey: NSUserDefaultKeys.NOTIFICATIONENABLED)
                }
                
                if let pushTokens = user["pushTokens"] as? [String] {
                    UserDefaults.setStringVal(value: pushTokens as AnyObject, forKey: NSUserDefaultKeys.PUSHTOKENS)
                } else {
                    UserDefaults.setStringVal(value: "" as AnyObject, forKey: NSUserDefaultKeys.PUSHTOKENS)
                }
                
                if let countFollowing = user["countFollowing"] as? Int {
                    UserDefaults.setIntVal(value: countFollowing as AnyObject, forKey: NSUserDefaultKeys.COUNTFOLLOWING)
                }
                
                if let countFlags = user["countFlags"] as? Int {
                    UserDefaults.setIntVal(value: countFlags as AnyObject, forKey: NSUserDefaultKeys.COUNTFLAGS)
                }
                
                UserDefaults.setStringVal(value: "" as AnyObject, forKey: NSUserDefaultKeys.PROFESSION)
            }
            
            if let meta = userData["meta"] as? [String: AnyObject] {
                
                if let url = meta["avatarURL"] as? String {

                    UserDefaults.setStringVal(value: url as AnyObject, forKey: NSUserDefaultKeys.AVATAREXTURL)
                }
            }
            
        }
        print_debug(object: "-------------User Detail's Saved.------------")
        
        
        print_debug(object: param)
        print_debug(object: CurrentUser.notificationsEnabled)
    }
    
}

struct SpotLight {
    let name : String!
    let description : String!
    let channelId : String!
    let imageUrl :  String!
}
