//
//  AllTagData.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 31/01/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class AllTagData{
    
    var description:String!
    init(data json:String) {
        
        self.description = json
        print(description)
    }
}
