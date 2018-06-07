//
//  NSDateExtension.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 08/10/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation


//MARK:- to get date....
extension Date {
    func yearsFrom(date:Date) -> Int{
        let components = Set<Calendar.Component>([.year])
        return Calendar.current.dateComponents(components, from: date, to: self).year ?? 0
    }
    func monthsFrom(date:Date) -> Int{
        let components = Set<Calendar.Component>([.month])
        return Calendar.current.dateComponents(components, from: date, to: self).month ?? 0
    }
    func weeksFrom(date:Date) -> Int{
        let components = Set<Calendar.Component>([.weekOfYear])
        return Calendar.current.dateComponents(components, from: date, to: self).weekOfYear ?? 0
    }
    func daysFrom(date:Date) -> Int{
        let components = Set<Calendar.Component>([.day])
        return Calendar.current.dateComponents(components, from: date, to: self).day ?? 0
    }
    func hoursFrom(date:Date) -> Int{
        let components = Set<Calendar.Component>([.hour])
        return Calendar.current.dateComponents(components, from: date, to: self).hour ?? 0
    }
    func minutesFrom(date:Date) -> Int{
        let components = Set<Calendar.Component>([.minute])
        return Calendar.current.dateComponents(components, from: date, to: self).minute ?? 0
    }
    func secondsFrom(date:Date) -> Int{
        let components = Set<Calendar.Component>([.second])
        return Calendar.current.dateComponents(components, from: date, to: self).second ?? 0
    }
    func offsetFrom(date:Date) -> String {
        if yearsFrom(date: date)   > 0 { return "\(yearsFrom(date: date))y"   }
        if monthsFrom(date: date)  > 0 { return "\(monthsFrom(date: date))M"  }
        if weeksFrom(date: date)   > 0 { return "\(weeksFrom(date: date))w"   }
        if daysFrom(date: date)    > 0 { return "\(daysFrom(date: date))d"    }
        if hoursFrom(date: date)   > 0 { return "\(hoursFrom(date: date))h"   }
        if minutesFrom(date: date) > 0 { return "\(minutesFrom(date: date))m" }
        if secondsFrom(date: date) > 0 { return "\(secondsFrom(date: date))s" }
        return ""
    }
}



// to do:

/*
 let date = Date()
 let calendar = Calendar.current
 let components = calendar.dateComponents([.year, .month, .day], from: date)
 
 let year =  components.year
 let month = components.month
 let day = components.day
 */
