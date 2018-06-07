//
//  ChannelUserDetail.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 03/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChannelUserData{
    
        var name:String         = ""
        var ageInYears          = ""
        var birth:String        = ""
        var born:String         = ""
        var nationality:String  = ""
        var height:String       = ""
        var netWorth:String     = ""
        var married:String      = ""
        var brand:String        = ""
    
    init(data json:JSON) {
       self.name        = json["name"].stringValue
       self.ageInYears  = json["ageInYears"].stringValue
       self.birth       = json["birthdayDisplay"].stringValue
       self.born        = json["birthPlace"].stringValue
       self.netWorth    = json["worthDisplay"].stringValue
       self.height      = json["height"].stringValue
       self.nationality = json["ethnicity"][0].stringValue
       self.married     = json["marStatus"][0].stringValue
   
    }
    
    var dictionary: [String: Any] {
        var dict = [String: Any]()
        
        dict["birth"]      = self.birth
        dict["born"]       = self.born
        dict["netWorth"]   = self.netWorth
        dict["nationality"] = self.nationality
        dict["height"]     = self.height
        dict["married"]    = self.married
        dict["name"]       = self.name

        return dict
    }
    
    
}
