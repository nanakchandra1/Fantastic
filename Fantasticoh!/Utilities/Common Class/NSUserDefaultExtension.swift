
//
//  NSUserDefaultExtension.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 26/08/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation

//MARK: UserDefault Extension
extension UserDefaults {
    
    
    class func setStringVal(value:AnyObject,forKey key:String)
    {
        UserDefaults.standard.set(value, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    class func setStringArrayVal(value:AnyObject,forKey key:String)
    {
        UserDefaults.standard.set(value, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    class func setCustomArrayVal(value:[AnyObject],forKey key:String)
    {
        let val = NSKeyedArchiver.archivedData(withRootObject: value)
        UserDefaults.standard.set(val, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    class func getCustomArrayVal(key:String) -> [AnyObject]?
    {
        let tempVal = UserDefaults.standard.object(forKey: key) as? NSData
        
        if let val = tempVal {
            if let getValue = NSKeyedUnarchiver.unarchiveObject(with: val as Data) as? [AnyObject] {
                return getValue
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    class func getStringVal(key:String) -> String?
    {
        if let value: String =  UserDefaults.standard.object(forKey: key) as? String {
            return value
        }
        return nil
    }
    
    
    class func getStringArrayVal(key:String) -> AnyObject?
    {
        if let value: AnyObject =  UserDefaults.standard.object(forKey: key) as AnyObject  {
            return value
        }
        return nil
    }
    
    class func setIntVal(value:AnyObject,forKey key:String)
    {
        UserDefaults.standard.set(value, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    class func getIntVal(key:String) -> Int?
    {
        if let value: Int =  UserDefaults.standard.object(forKey: key) as? Int {
            return value
        }
        return nil
    }
    
    class func setBoolVal(state:Bool,forKey key:String) {
        UserDefaults.standard.set(state, forKey: key)
        UserDefaults.standard.synchronize();
    }
    
    
    class func getBoolVal(key:String) -> Bool?
    {
        if let val = UserDefaults.standard.value(forKey: key) as? Bool {
            return val
        }
        return nil
    }
    
    class func clean() {
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize()
    }
    
    
    /*
    class func save(value:AnyObject,forKey key:String)
    {
        UserDefaults.standard.setObject(value, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    class func userDefaultForKey(key:String) -> AnyObject?
    {
        if let value: AnyObject =  UserDefaults.standard.objectForKey(key) {
            return value
        } else {
            return nil
        }
    }
    
    class func getAnyDataFromUserDefault(key:String) -> String?
    {
        if let value = UserDefaults.standard.objectForKey(key) as? String {
            return value
        }
        return nil
    }
    class func getDataFromUserDefault(key:String) -> AnyObject?
    {
        if let value: AnyObject = UserDefaults.standard.objectForKey(key) {
            
            return value
        }
        return nil
    }
    
    class func userDefaultForBool(key:String) -> AnyObject
    {
        return UserDefaults.standard.objectForKey(key) ?? false
    }
    
    
    class func saveBoolInDefaultkey(key:String,state:Bool) {
        UserDefaults.standard.setBool(state, forKey: key);
        UserDefaults.standard.synchronize();
    }
    
    
    class func getBoolFromDefault(key:String)->Bool?
    {
        if let val = UserDefaults.standard.valueForKey(key) as? Bool {
            return val
        }
        return nil
    }
    
    class func saveDoubleInDefaultkey(key:String,value:Double) {
        
        UserDefaults.standard.setDouble(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getDoubleFromUserDefault(key:String)->Double?
    {
        
        if let val = UserDefaults.standard.valueForKey(key) as? Double {
            return val
        }
        return nil
    }
    
    
    
    class func fetchBool(key:String)->Bool{
        
        //        if id = UserDefaults.getAnyDataFromUserDefault("userId"){
        //
        //            return true
        //        }
        return UserDefaults.standard.boolForKey(key);
    }
    
    
    
    
    //    class func removeFromUserDefault(key:String) {
    //        UserDefaults.standard.removeObjectForKey(key);
    //        UserDefaults.standard.synchronize()
    //    }
    class func userdefaultStringForKey(key:String) -> String?
    {
        if let value =  UserDefaults.standard.objectForKey(key) as? String {
            return value
        } else {
            return nil
        }
    }
    
    //    class func removeFromUserDefaultForKey(key:String)
    //    {
    //        UserDefaults.standard.removeObjectForKey(key)
    //        UserDefaults.standard.synchronize()
    //    }
    
    
    class func clean()
    {
        let appDomain = NSBundle.mainBundle().bundleIdentifier!
        UserDefaults.standard.removePersistentDomainForName(appDomain)
        UserDefaults.standard.synchronize()
        
    }
    */
}
