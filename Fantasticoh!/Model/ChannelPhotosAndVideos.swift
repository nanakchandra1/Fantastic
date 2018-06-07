//
//  ChannelPhotosAndVideos.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 05/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import Foundation
import SwiftyJSON
class ChannelPhotosAndVideos{
    
    var tag          :String = ""
    var tagDisplay   :String = ""
    var includeNonGraphBeeps  :String = ""
    var hashtags      = [String]()
    var beeps        = [[String:AnyObject]]()

   
    
    init(data json: JSON) {
      
        
        self.tag                  = json["tag"].stringValue
        self.includeNonGraphBeeps = json["includeNonGraphBeeps"].stringValue
        self.tagDisplay           = json["tagDisplay"].stringValue
        if let array              = json["hashtags"].arrayObject as? [String] {
            hashtags = array
        }
        if let array              = json["beeps"].arrayObject as? [[String:AnyObject]] {
           beeps = array
        }
    }
    
    
    var dictionary: [String: Any] {
        var dict = [String: Any]()
        
        dict["tagDisplay"]      = self.tagDisplay
    
        return dict
    }
}
