//
//  StringExtension.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 11/08/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation
import UIKit

//MARK: extension for String to get character & string of given index.
extension String {
    
    subscript (i: Int) -> Character {
        return self[self.index(after: self.startIndex)]
    }
    subscript (i: Int) -> String {
        return String(self[self.index(after: self.startIndex)])
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil
    }
    
    var removeExcessiveSpaces: String {
        let components = self.components(separatedBy: NSCharacterSet.whitespaces)
        let filtered = components.filter({!$0.isEmpty})
        return filtered.joined(separator: " ")
    }
    
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: String.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
    
    func getSearchFormatedString() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
