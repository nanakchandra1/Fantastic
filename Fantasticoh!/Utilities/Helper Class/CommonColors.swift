//
//  CommonColors.swift
//  Fantasticoh!
//
//  Created by Shubham on 8/2/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    //MARK:- To give the RGB value
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

class CommonColors {
    
    class func fbBtnColor()-> UIColor {
    
        return UIColor(red: 45.0/255.0, green: 68.0/255.0, blue: 134.0/255.0, alpha: 1)
    }
    
    class func googleBtnColor()-> UIColor {
        
        return UIColor(red: 202.0/255.0, green: 51.0/255.0, blue: 42.0/255.0, alpha: 1)
    }
    
    class func globalRedColor()-> UIColor {
        
        return UIColor(red: 247.0/255.0, green: 0.0/255.0, blue: 47.0/255.0, alpha: 1)
    }
    
    class func lightGrayColor()-> UIColor {
    
        return UIColor(red: 135.0/255.0, green: 135.0/255.0, blue: 135.0/255.0, alpha: 1)
    }
    
    class func btnTextColor()-> UIColor {
        
        return UIColor(red: 163.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1)
    }
    
    class func btnTitleColor()-> UIColor {
        
        return UIColor(red: 116.0/255.0, green: 116.0/255.0, blue: 116.0/255.0, alpha: 1)
    }
    
    class func lblTextColor()-> UIColor {
        
        return UIColor(red: 38.0/255.0, green: 38.0/255.0, blue: 38.0/255.0, alpha: 1)
    }
    
    class func fanlblTextColor()-> UIColor {
        
        return UIColor(red: 84.0/255.0, green: 84.0/255.0, blue: 84.0/255.0, alpha: 1)
    }
    
    class func whiteColor()-> UIColor {
        
        return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
    
    class func tabBarLblGrayColor()-> UIColor {
        
        return UIColor(red: 147.0/255.0, green: 147.0/255.0, blue: 147.0/255.0, alpha: 1)
    }
    
    class func sepratorColor()-> UIColor {
        
        return UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    }
    
    class func fanGreenBtnColor()-> UIColor {
        
        return UIColor(red: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255.0, alpha: 1)
    }
    
    class func tableSectionHeaderBGColor()-> UIColor {
        
        return UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1)
    }
    
    class func tableSectionHeaderTextColor()-> UIColor {
        
        return UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1)
    }
    
    class func refferalCodeBorderColor()-> UIColor {
        
        return UIColor(red: 115.0/255.0, green: 115.0/255.0, blue: 115.0/255.0, alpha: 0.7)
    }
    
}