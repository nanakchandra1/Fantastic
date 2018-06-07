//
//  SQLiteManager.swift
//  Fantasticoh!
//
//  Created by Aishwarya Rastogi on 30/11/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import Foundation
import SQLite
import SwiftyJSON

enum SQLiteSportLightObjectManager{
    
    enum Database: String{
        
        case dbName = "SpotLight.sqlite"
    }
    
    static var dataBase : Connection? = nil
    
    static var dataBaseConnection  : Connection? {
        get {
            do{
                let databaseFilePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(Database.dbName.rawValue)"
                dataBase = try Connection(databaseFilePath)
                return  dataBase
            } catch let error{
                print(" \(error)")
            }
            return nil
        }
    }
    
    /** Creates table if not exists*/
    static func createTable(){
        
        do{
            _ = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(Database.dbName.rawValue)"
            // let db = try Connection(databaseFilePath)
            
            guard let db = dataBaseConnection else {
                return
            }
            
            let mediaTable = Table(TableName.spotLight.rawValue)
            
            let name = Expression<String>("name")
            let id = Expression<String>("id")
            let decs = Expression<String>("desc")
            let url = Expression<String>("url")
            let status = Expression<Bool>("status")
            
            
            try db.run(mediaTable.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(decs)
                t.column(url)
                t.column(status)
            })
            
        } catch let error{
            print(" \(error)")
        }
    }
    
    static func insertSportLight(_ object: SportLightObject, _ sportLightId: String){
        
        do{
            let databaseFilePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(Database.dbName.rawValue)"
            let db = try Connection(databaseFilePath)
            
            let files = Table(TableName.spotLight.rawValue)
            
            let name = Expression<String>("name")
            let id = Expression<String>("id")
            let decs = Expression<String>("desc")
            let url = Expression<String>("url")
            let status = Expression<Bool>("status")
            
            
            try db.transaction {
                                let insert = files.insert(name   <- object.name,
                                                               id    <- object.id,
                                                               decs  <- object.decs,
                                                               url   <- object.url,
                                                               status    <- object.status)
                                
                                try db.run(insert)
                                
                
            
            }
            
        } catch let error{
            print(error)
        }
    }
    
    @discardableResult
    static func updateSpotLightFiles(_ spotLightId: String,_ SportLightObject: SportLightObject)->Bool{
        
        do{
            _ = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(Database.dbName.rawValue)"

            let table = Table(TableName.spotLight.rawValue)
            
            guard let db = dataBase else {
                return false
            }
            
            let name = Expression<String>("name")
            let id = Expression<String>("id")
            let decs = Expression<String>("desc")
            let url = Expression<String>("url")
            let status = Expression<Bool>("status")
            
            
            let spotLightUpdate = table.filter(id == spotLightId)
            
            if try db.run(spotLightUpdate.update(name <- SportLightObject.name, decs <- SportLightObject.decs, url <- SportLightObject.url, status <- SportLightObject.status)) > 0 {
                
                print("Updated Uploading status: sucess")
                return true
            } else {
                print("Cannot update")
                return false
            }
            
        } catch let error{
            print(error)
            return false
        }
    }
    

    static func getAllSpotLight()->[SportLightObject]{

        var sentMedia: [SportLightObject] = []

        do{
            _ = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(Database.dbName.rawValue)"
            //     let db = try Connection(databaseFilePath)
            let files = Table(TableName.spotLight.rawValue)
            guard let db = dataBase else {
                return sentMedia
            }
            let name = Expression<String>("name")
            let id = Expression<String>("id")
            let decs = Expression<String>("desc")
            let url = Expression<String>("url")
            let status = Expression<Bool>("status")
            

            do{
                for files in try db.prepare(files) {

                    var msg: [String:Any] = [:]
                    msg["name"] = files[name]
                    msg["id"] = files[id]
                    msg["decs"] = files[decs]
                    msg["url"] = files[url]
                    msg["status"] = files[status]

                    let message = SportLightObject(withData: JSON(msg))

                    sentMedia.append(message)
                }
            }
        }catch let error{
            print("\(error)")
        }
        return sentMedia
    }

    
//    static func getSpotLight(spotLightId: String)->SportLightObject?{
//
//        var sentMedia: SportLightObject?
//
//        do{
//            _ = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(Database.dbName.rawValue)"
//
//            //       let db = try Connection(databaseFilePath)
//            let files = Table(TableName.spotLight.rawValue)
//            guard let db = dataBaseConnection else {
//                return sentMedia
//            }
//            //let mediaTable = Table(TableName.spotLight.rawValue)
//
//            let name = Expression<String>("name")
//            let id = Expression<String>("id")
//            let decs = Expression<String>("desc")
//            let url = Expression<String>("url")
//            let status = Expression<Bool>("status")
//
//
//            let results = files.filter(id == spotLightId)
//
//            do{
//                for files in try db.prepare(results) {
//
//                    var msg: [String:Any] = [:]
//                    msg["name"] = try files.get(name)
//                    msg["id"] = try files.get(id)//files[id]
//                    msg["decs"] = try files.get(decs)//files[decs]
//                    msg["url"] = try files.get(url)//files[url]
//                    msg["status"] = try files.get(status)//files[status]
//
//                    let value = SportLightObject(withData: JSON(msg))
//                    sentMedia = value
//                }
//            }
//        }catch let error{
//            print("\(error)")
//        }
//        return sentMedia
//    }
//
        static func getSpotLight(spotLightId: String)->Bool?{
    
            var sentMedia: SportLightObject?
    
            do{
                _ = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(Database.dbName.rawValue)"
    
                //       let db = try Connection(databaseFilePath)
                let files = Table(TableName.spotLight.rawValue)
                guard let db = dataBaseConnection else {
                    return sentMedia  == nil ? false : true
                }
                //let mediaTable = Table(TableName.spotLight.rawValue)
    
                let name = Expression<String>("name")
                let id = Expression<String>("id")
                let decs = Expression<String>("desc")
                let url = Expression<String>("url")
                let status = Expression<Bool>("status")
    
    
                let results = files.filter(id == spotLightId)
               
                do{
                    for files in try db.prepare(results) {
    
                        var msg: [String:Any] = [:]
                        msg["name"] = try files.get(name)
                        msg["id"] = try files.get(id)//files[id]
                        msg["decs"] = try files.get(decs)//files[decs]
                        msg["url"] = try files.get(url)//files[url]
                        msg["status"] = try files.get(status)//files[status]
    
                        let value = SportLightObject(withData: JSON(msg))
                        sentMedia = value
                    }
                }
            }catch let error{
                print("\(error)")
               
            }
            return sentMedia == nil ? false : true
        }
    
    
    static func delete(files messageId: String)->Bool{
        
        do{
            _ = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(Database.dbName.rawValue)"
            
            //    let db = try Connection(databaseFilePath)
            
            let table = Table(TableName.spotLight.rawValue)
            guard let db = dataBase else {
                return false
            }
            
            let mId = Expression<String>("id")
            
            let msg = table.filter(messageId == mId)
            
            if try db.run(msg.delete()) > 0 {
                
                print("deleted Message: \(messageId)")
                return true
            } else {
                
                return false
            }
            
        }catch let error{
            
            print("Delete Media files: \(error) ")
            
            return false
        }
        
    }
    
    
    static func deleteTable()->Bool{
        
        do{
            _ = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(Database.dbName.rawValue)"
            
            //    let db = try Connection(databaseFilePath)
            
            let table = Table(TableName.spotLight.rawValue)
            
            guard let db = dataBase else {
                return false
            }
            
            if try db.run(table.delete()) > 0 {
                
                print("table Deleted")
                return true
            } else {
                
                return false
            }
            
        }catch let error{
            
            print("Delete Media files: \(error) ")
            
            return false
        }
        
    }
    
    
    
}

class SportLightObject: Equatable{
    static func ==(left:SportLightObject, right:SportLightObject) -> Bool {
        return left.id == right.id
    }
    var name: String
    var id: String
    var decs: String
    var url: String
    var status: Bool
 
    init(withData data: JSON){
        name = data[SportLightObjectEnum.name.rawValue].stringValue
        id = data[SportLightObjectEnum.id.rawValue].stringValue
        decs = data[SportLightObjectEnum.decs.rawValue].stringValue
        url = data[SportLightObjectEnum.url.rawValue].stringValue
        status = data[SportLightObjectEnum.status.rawValue].boolValue
    }
}

enum SportLightObjectEnum: String{
    case name = "name"
    case id = "id"
    case decs = "decs"
    case url = "url"
    case status = "status"
 
}

enum TableName: String{

    case spotLight = "spotLight"
}


