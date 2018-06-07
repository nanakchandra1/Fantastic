//
//  SeeAllPhotosAndVideos.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 06/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class SeeAllPhotosAndVideos{
    
    var id          :String = ""
    var postTimeDisplay  :String = ""
    var postTime  :String = ""
    var image2x    :String = ""
    var title      :String = ""
    var imageHeight      :CGFloat = 0.0
    var imageWeight      :CGFloat = 0.0
    
    
    init(data json: JSON) {
        
        self.id                    = json["id"].stringValue
        self.postTimeDisplay       = json["postTimeDisplay"].stringValue
        self.postTime              = json["postTime"].stringValue
        self.image2x               = json["img2x"].stringValue
        self.imageHeight           = CGFloat(json["img2xH"].intValue)
        self.imageWeight           = CGFloat(json["img2xW"].intValue)
         self.title              = json["title"].stringValue
        
    }
    
    var dictionary: [String: Any] {
        var dict = [String: Any]()
        
        dict["id"]               = self.id
        dict["postTimeDisplay"]  = self.postTimeDisplay
        dict["postTime"]         = self.postTime
        dict["image2x"]          = self.image2x
        dict["title"]            = self.title
        
        return dict
    }
    
}
