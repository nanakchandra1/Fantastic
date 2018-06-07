 //
 //  GSNetworking.swift
 //  BigBrotherApp
 //
 //  Created by playidiot on 21/05/15.
 //  Copyright (c) 2015 AppInventiv. All rights reserved.
 //
 
 import UIKit
 import SystemConfiguration
 
 typealias JSONDictionary = [String : AnyObject]
 typealias JSONDictionaryArray = [[String : AnyObject]]
 
 let NO_INTERNET_MSG = "Internet Not Available"
 let NO_INTERNET_ERROR_CODE = -100
 let WEBSERVICE_TIMEOUT_INTERVAL = 5.0
 let api_key = ""
 public final class GSNetworking {
    
    internal typealias webServiceSuccess = (_ JSON : [String : AnyObject]) -> Void
    internal typealias webServiceFailure = (_ error : NSError) -> Void
    
    internal typealias webServiceWithHeaderSuccess = (_ JSONHeaderResponse : [String : AnyObject], _ JSONResultResponse : AnyObject) -> Void
    
    internal typealias webServiceJSONArraySuccess = (_ JSONHeaderResponse : [String : AnyObject], _ JSONResultResponse : [AnyObject]) -> Void
    
    internal typealias customSuccessClosure = (_ JSON : [AnyObject]) -> Void
    
    class func POSTWITHJSON(URLString: String!, parameters: JSONDictionary, successBlock: @escaping webServiceSuccess  , failureBlock: @escaping webServiceFailure) {
        
        if !GSNetworking.isConnectedToNetwork {
            
            let errorUserInfo =
                [   NSLocalizedDescriptionKey : NO_INTERNET_MSG,
                    NSURLErrorFailingURLErrorKey : "\(URLString)"
            ]
            
            let noInternetError =  NSError(domain: NSCocoaErrorDomain, code: NO_INTERNET_ERROR_CODE, userInfo:errorUserInfo)
            
            //CommonClass.showAlertText("Internet Not Available")
            
            failureBlock(noInternetError)
            
            return
        }
        
         print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH GET PARAMETERS\n\n\(parameters)")
        
        let manager = AFHTTPRequestOperationManager()
        
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "api-key")
        
       // print_debug(object: "\n\nRequest Header \n\n\n\(manager.requestSerializer.httpRequestHeaders)")
        
        manager.post(URLString, parameters: parameters,
                     
                     success: { (operation , responseObject) -> Void in
                        
                        //CommonClass.stopLoader()
                        
                        print_debug(object: "========\(parameters)=========")
                        
                        print_debug(object: responseObject)
                        //                print_debug(object: "\n\n\n                  HITTING URL\n\n \(URLString)\n\n\n                  WITH GET PARAMETERS\n\n\(parameters)\n\n\n                  WITH ACCESS TOKEN\n\n\(accessToken)")
                        
                        let decodedStr = NSString(data: (responseObject as! NSData) as Data, encoding: 4)
                        
                        print_debug(object: "\n\nRECEIVED DATA BEFORE PARSING IS \n\n\n\(String(describing: decodedStr))")
                        
                        let json: AnyObject? = try? JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        if let jsonDict = json as? [String:AnyObject] {
                            
                            print_debug(object: "\n\nRECEIVED DATA AFTER PARSING IS \n\n\n\(jsonDict)")
                            successBlock(jsonDict)
                            
                        } else {
                            
                            let errorUserInfo =
                                [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
                                    NSURLErrorFailingURLErrorKey : "\(URLString)"
                            ]
                            
                            let jsonError =  NSError(domain: NSCocoaErrorDomain, code: -101, userInfo:errorUserInfo)
                            
                            failureBlock(jsonError)
                        }
                        
        }) { (operation, error) -> Void in
            
            print_debug(object: "\n\n\n                  HITTING URL\n\n \(URLString)\n\n\n                  WITH GET PARAMETERS\n\n\(parameters)")
            
            failureBlock(error! as NSError)
        }
        
    }
    
    class func POSTWITHIMAGE(URLString: String!, parameters: JSONDictionary,image:[String:UIImage?] ,successBlock: @escaping webServiceSuccess  , failureBlock: @escaping webServiceFailure) {
        
        if !GSNetworking.isConnectedToNetwork {
            
            let errorUserInfo =
                [   NSLocalizedDescriptionKey : NO_INTERNET_MSG,
                    NSURLErrorFailingURLErrorKey : "\(URLString)"
            ]
            
            let noInternetError =  NSError(domain: NSCocoaErrorDomain, code: NO_INTERNET_ERROR_CODE, userInfo:errorUserInfo)
            
            //CommonClass.showAlertText("Internet Not Available")
            
            failureBlock(noInternetError)
            
            return
        }
        
         print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH GET PARAMETERS\n\n\(parameters)")
        
        let manager = AFHTTPRequestOperationManager(baseURL: nil)
        
        manager?.responseSerializer = AFHTTPResponseSerializer()
        manager?.requestSerializer = AFJSONRequestSerializer()
        
        //        var imageData : NSData?
        //        if let userImage = image.first!{
        //
        //           imageData  = UIImageJPEGRepresentation(userImage, 1.0)!
        //            parameters["user_image"] = imageData
        //        }
        
       _ = manager?.post(URLString , parameters: parameters,
                      constructingBodyWith: { (data) in
                        
                        //print_debug(object: imageData)
                        print_debug(object: parameters)
                        
                        for (key,value) in image {
                            var imageData : NSData?
                            
                            if let userImage = value{
                                
                                imageData  = UIImageJPEGRepresentation(userImage, 0.7)! as NSData
                                //parameters["user_image"] = imageData
                                if let image_data =  imageData {
                                    
                                    data?.appendPart(withFileData: image_data as Data!, name: key, fileName:"images.jpg", mimeType:"image/jpeg")
                                }
                            }
                        }
                        
        },
                      success: { (operation, responseObject) -> Void in
                        
                        // CommonClass.stopLoader()
                        
                        print_debug(object: "========\(parameters)=========")
                        
                        print_debug(object: responseObject)
                        //                print_debug(object: "\n\n\n                  HITTING URL\n\n \(URLString)\n\n\n                  WITH GET PARAMETERS\n\n\(parameters)\n\n\n                  WITH ACCESS TOKEN\n\n\(accessToken)")
                        
                        let decodedStr = NSString(data: (responseObject as! NSData) as Data, encoding: 4)
                        
                        print_debug(object: "\n\nRECEIVED DATA BEFORE PARSING IS \n\n\n\(String(describing: decodedStr))")
                        
                        let json: AnyObject? = try? JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        if let jsonDict = json as? [String:AnyObject] {
                            
                            print_debug(object: "\n\nRECEIVED DATA AFTER PARSING IS \n\n\n\(jsonDict)")
                            successBlock(jsonDict)
                            
                        } else {
                            
                            let errorUserInfo =
                                [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
                                    NSURLErrorFailingURLErrorKey : "\(URLString)"
                            ]
                            
                            let jsonError =  NSError(domain: NSCocoaErrorDomain, code: -101, userInfo:errorUserInfo)
                            
                            failureBlock(jsonError)
                        }
                        
        },
                      failure: { (operation, error) in
                        
                        //CommonClass.stopLoader()
                        print_debug(object: error?.localizedDescription)
        })
    }
    
//    class func POST(URLString: String!, parameters: AnyObject!, successBlock: @escaping webServiceSuccess  , failureBlock: @escaping webServiceFailure) {
//        
//        if !GSNetworking.isConnectedToNetwork {
//            
//            let errorUserInfo =
//                [   NSLocalizedDescriptionKey : NO_INTERNET_MSG,
//                    NSURLErrorFailingURLErrorKey : "\(URLString)"
//            ]
//            
//            let noInternetError =  NSError(domain: NSCocoaErrorDomain, code: NO_INTERNET_ERROR_CODE, userInfo:errorUserInfo)
//            
//            //CommonClass.showAlertText("Internet Not Available")
//            
//            failureBlock(noInternetError)
//            
//            return
//        }
//        
//        var postStr = ""
//        let params = parameters as! [String:AnyObject]
//        
//        for (key,value) in params {
//            postStr.append("\(key)=\(value)&")
//        }
//        
//        postStr.remove(at: postStr.index(postStr.endIndex, offsetBy: -1))
//        
//        let postData = postStr.data(using: String.Encoding.utf8, allowLossyConversion: false)
//        
//        let postLength = "\(postData?.count)"
//        
//        print_debug(object: "\(URLString)\(postStr)")
//        
//        print_debug(object: "postData====\(postData)")
//        
//        let request = NSMutableURLRequest(url: URL(string: URLString)!)
//        request.timeoutInterval = WEBSERVICE_TIMEOUT_INTERVAL
//        
//        request.httpMethod = "POST"
//        request.setValue(api_key, forHTTPHeaderField: "api-key")
//        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpBody = postData
//        
//        print_debug(object: request.url)
//        
//        let operation = AFHTTPRequestOperation(request: request as URLRequest!)
//        
//        operation?.setCompletionBlockWithSuccess({ (_, responseObj )  in
//            
//            print_debug(object: "\n\n\n                  HITTING URL\n\n \(URLString)\n\n\n                  WITH POST PARAMETERS\n\n\(parameters)");
//            
//            let data = responseObj as! NSData
//            
//            print_debug(object: "\n\nRECEIVED DATA BEFORE PARSING IS \n\n\n\(String(describing: NSString(data: data, encoding: 4)))")
//            
//            do {
//                
//                if let jsonDict = try JSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.mutableContainers) as? [String:AnyObject] {
//                    
//                    print_debug(object: "\n\nRECEIVED DATA AFTER PARSING IS \n\n\n\(jsonDict)")
//                    
//                    successBlock(JSON: jsonDict)
//                    
//                } else {
//                    
//                    let errorUserInfo =
//                        [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
//                            NSURLErrorFailingURLErrorKey : "\(URLString)"
//                    ]
//                    
//                    let jsonError =  NSError(domain: NSCocoaErrorDomain, code: -101, userInfo:errorUserInfo)
//                    
//                    failureBlock(jsonError)
//                    
//                }
//                
//            } catch let err as NSError {
//                
//                print_debug(object: err.localizedDescription)
//            }
//            
//        }, failure: { (_, error ) -> Void in
//            
//            
//            
//            failureBlock(error)
//        })
//        
//        operation?.start()
//        
//        
//    }
    
//    class func POSTForSignUp(URLString: String!, parameters: AnyObject! , successBlock: @escaping webServiceSuccess,  failureBlock: @escaping webServiceFailure) {
//        
//        if !GSNetworking.isConnectedToNetwork {
//            
//            let errorUserInfo =
//                [   NSLocalizedDescriptionKey : NO_INTERNET_MSG,
//                    NSURLErrorFailingURLErrorKey : "\(URLString)"
//            ]
//            
//            let noInternetError =  NSError(domain: NSCocoaErrorDomain, code: NO_INTERNET_ERROR_CODE, userInfo:errorUserInfo)
//            
//            //CommonClass.showAlertText("Internet Not Available")
//            
//            failureBlock(noInternetError)
//            
//            return
//        }
//        
//        print_debug(object: "\n\n <------- HITTING URL -------> \n\n \(URLString)\n\n <------- WITH POST PARAMETERS <------- \n\n\(parameters)");
//        
//        let manager = AFHTTPRequestOperationManager()
//        manager.responseSerializer = AFHTTPResponseSerializer()
//        manager.requestSerializer = AFHTTPRequestSerializer()
//        manager.requestSerializer.timeoutInterval  = WEBSERVICE_TIMEOUT_INTERVAL
//        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "api-key")
//        manager.POST(URLString, parameters: parameters,
//                     
//                     success: { (operation, responseObject) -> Void in
//                        
//                        print_debug(object: "responseObject:===\(responseObject)")
//                        let decodedStr = NSMutableString(data: (responseObject as! NSData), encoding: 0)
//                        
//                        print_debug(object: "\n\n <---- RECEIVED DATA BEFORE PARSING IS ------> \n\n \(decodedStr!)")
//                        
//                        let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData((responseObject as! NSData), options: NSJSONReadingOptions.MutableContainers)
//                        
//                        if let jsonDict = json as? [String:AnyObject]
//                        {
//                            print_debug(object: "\n\n <----> RECEIVED DATA AFTER PARSING IS <----> \n\n\(jsonDict)")
//                            successBlock(JSON: jsonDict)
//                            // DataBaseController.sharedInstance.insertDataInCampaign(jsonDict)
//                        }
//                        else
//                        {
//                            let errorUserInfo =
//                                [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
//                                    NSURLErrorFailingURLErrorKey : "\(URLString)"
//                            ]
//                            
//                            let jsonError =  NSError(domain: NSCocoaErrorDomain, code: -101, userInfo:errorUserInfo)
//                            
//                            failureBlock(error: jsonError)
//                        }
//                        
//        }, failure: { (operation, error)  in
//            
//            failureBlock(error)
//        })
//    }
    
    class func DELETE(URLString: String!, parameters: AnyObject!, successBlock: @escaping webServiceSuccess  , failureBlock: @escaping webServiceFailure) {
        
        if !GSNetworking.isConnectedToNetwork {
            
            let errorUserInfo =
                [   NSLocalizedDescriptionKey : NO_INTERNET_MSG,
                    NSURLErrorFailingURLErrorKey : "\(URLString)"
            ]
            
            let noInternetError =  NSError(domain: NSCocoaErrorDomain, code: NO_INTERNET_ERROR_CODE, userInfo:errorUserInfo)
            
            //CommonClass.showAlertText("Internet Not Available")
            
            failureBlock(noInternetError)
            
            return
        }
         print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH GET PARAMETERS\n\n\(parameters)")
        let manager = AFHTTPRequestOperationManager()
        
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "api-key")
        
        manager.delete(URLString, parameters: parameters,
                       
                       success: { (operation, responseObject) -> Void in
                        
                        //CommonClass.stopLoader()
                        
                        print_debug(object: "========\(parameters)=========")
                        
                        
                        print_debug(object: responseObject)
                        //                print_debug(object: "\n\n\n                  HITTING URL\n\n \(URLString)\n\n\n                  WITH GET PARAMETERS\n\n\(parameters)\n\n\n                  WITH ACCESS TOKEN\n\n\(accessToken)")
                        
                        let decodedStr = NSString(data: (responseObject as! NSData) as Data, encoding: 4)
                        
                        print_debug(object: "\n\nRECEIVED DATA BEFORE PARSING IS \n\n\n\(String(describing: decodedStr))")
                        
                        let json: AnyObject? = try? JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        if let jsonDict = json as? [String:AnyObject] {
                            
                            print_debug(object: "\n\nRECEIVED DATA AFTER PARSING IS \n\n\n\(jsonDict)")
                            successBlock(jsonDict)
                            
                        } else {
                            
                            let errorUserInfo =
                                [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
                                    NSURLErrorFailingURLErrorKey : "\(URLString)"
                            ]
                            
                            let jsonError =  NSError(domain: NSCocoaErrorDomain, code: -101, userInfo:errorUserInfo)
                            
                            failureBlock(jsonError)
                        }
                        
        }) { (operation, error) -> Void in
            
            print_debug(object: "\n\n\n                  HITTING URL\n\n \(URLString)\n\n\n                  WITH GET PARAMETERS\n\n\(parameters)")
            
            failureBlock(error! as NSError)
        }
    }
    
//    class func PUT(URLString: String!, parameters: AnyObject!, successBlock: @escaping webServiceSuccess  , failureBlock: @escaping webServiceFailure) {
//        
//        if !GSNetworking.isConnectedToNetwork {
//            
//            let errorUserInfo =
//                [   NSLocalizedDescriptionKey : NO_INTERNET_MSG,
//                    NSURLErrorFailingURLErrorKey : "\(URLString) "
//            ]
//            
//            let noInternetError =  NSError(domain: NSCocoaErrorDomain, code: NO_INTERNET_ERROR_CODE, userInfo:errorUserInfo)
//            
//            //CommonClass.showAlertText("Internet Not Available")
//            
//            failureBlock(noInternetError)
//            
//            return
//        }
//        
//        var postStr = ""
//        let params = parameters as! [String:AnyObject]
//        
//        for (key,value) in params {
//            postStr.append("\(key)=\(value)&")
//        }
//        postStr.remove(at: postStr.index(postStr.endIndex, offsetBy: -1))
//        
//        let postData = postStr.data(using: String.Encoding.ascii, allowLossyConversion: false)
//        let postLength = "\(String(describing: postData?.count))"
//        
//        print_debug(object: "\(URLString)\(postStr)")
//        
//        let request = NSMutableURLRequest(url: URL(string: URLString)!)
//        request.timeoutInterval = WEBSERVICE_TIMEOUT_INTERVAL
//        
//        request.httpMethod = "PUT"
//        request.setValue(api_key, forHTTPHeaderField: "api-key")
//        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpBody = postData
//        
//        print_debug(object: request.url)
//        
//        let operation = AFHTTPRequestOperation(request: request as URLRequest!)
//        
//        operation?.setCompletionBlockWithSuccess({ (_, responseObj ) -> Void in
//            
//            print_debug(object: "\n\n\n                  HITTING URL\n\n \(URLString)\n\n\n                  WITH POST PARAMETERS\n\n\(parameters)");
//            
//            let data = responseObj as! NSData
//            
//            print_debug(object: "\n\nRECEIVED DATA BEFORE PARSING IS \n\n\n\(NSString(data: data as Data, encoding: 4))")
//            
//            do {
//                
//                if let jsonDict = try JSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? [String:AnyObject] {
//                    
//                    print_debug(object: "\n\nRECEIVED DATA AFTER PARSING IS \n\n\n\(jsonDict)")
//                    
//                    successBlock(JSON: jsonDict)
//                    
//                } else {
//                    
//                    let errorUserInfo =
//                        [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
//                            NSURLErrorFailingURLErrorKey : "\(URLString)"
//                    ]
//                    
//                    let jsonError =  NSError(domain: NSCocoaErrorDomain, code: -101, userInfo:errorUserInfo)
//                    
//                    failureBlock(jsonError)
//                }
//                
//            } catch let err as NSError {
//                
//                print_debug(object: err.localizedDescription)
//            }
//            
//        }, failure: { (operation, error )  in
//            
//            
//            failureBlock(error)
//        })
//        
//        operation?.start()
//        
//    }
    
    
    class func GET(URLString: String!, parameters: AnyObject!, successBlock: webServiceSuccess, failureBlock: @escaping webServiceFailure) {
        
         print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH GET PARAMETERS\n\n\(parameters)")
        let manager = AFHTTPRequestOperationManager()
        
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.requestSerializer = AFHTTPRequestSerializer()
        
        //manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "api-key")
        
        manager.get(URLString, parameters: parameters,
                    
                    success: { (operation, responseObject) -> Void in
                        
                        //CommonClass.stopLoader()
                        
                        //                print_debug(object: "\n\n\n                  HITTING URL\n\n \(URLString)\n\n\n                  WITH GET PARAMETERS\n\n\(parameters)\n\n\n                  WITH ACCESS TOKEN\n\n\(accessToken)")
                        
                        let decodedStr = NSString(data: (responseObject as! NSData) as Data, encoding: 4)
                        
                        print_debug(object: "\n\nRECEIVED DATA BEFORE PARSING IS \n\n\n\(String(describing: decodedStr))")
                        
                        let json: AnyObject? = try? JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        if let jsonDict = json as? [String : AnyObject] {
                            
                            print_debug(object: "\n\nRECEIVED DATA AFTER PARSING IS \n\n\n\(jsonDict)")
                            //successBlock(JSON: jsonDict)
                            
                        } else {
                            
                            let errorUserInfo =
                                [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
                                    NSURLErrorFailingURLErrorKey : "\(URLString)"
                            ]
                            
                            let jsonError =  NSError(domain: NSCocoaErrorDomain, code: -101, userInfo:errorUserInfo)
                            
                            failureBlock(jsonError)
                        }
                        
        }) { (operation, error) -> Void in
            
            //CommonClass.stopLoader()
            print_debug(object: "\n\n\n                  HITTING URL\n\n \(URLString)\n\n\n                  WITH GET PARAMETERS\n\n\(parameters)")
            
            failureBlock(error! as NSError)
        }
    }
    
    
    
    //MARK:- GET Method
    class func GET_CUSTOM(URLString: String!, parameters: AnyObject!, successBlock: @escaping customSuccessClosure, failureBlock: @escaping webServiceFailure) {
        print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH GET PARAMETERS\n\n\(parameters)")
        
        let manager = AFHTTPRequestOperationManager()
        
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.requestSerializer = AFHTTPRequestSerializer()
        
        //manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "api-key")
        
        if let authCookieAddress = UserDefaults.getStringVal(key: NSUserDefaultKeys.COOKIEADDRESS) {
            print_debug(object: "Auth")
            print_debug(object: "x-bbsc : \(authCookieAddress)" )
            manager.requestSerializer.setValue(authCookieAddress, forHTTPHeaderField: "x-bbsc")
        } else {
            print_debug(object: "Guest")
            print_debug(object: "x-bbsc : \(GUEST_COOKIE_ADDRESS)" )
            manager.requestSerializer.setValue(GUEST_COOKIE_ADDRESS, forHTTPHeaderField: "x-bbsc")
        }
        
        manager.get(URLString, parameters: parameters,
                    
                    success: { (operation, responseObject) -> Void in
                        
                        //CommonClass.stopLoader()
                        
                        print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH GET PARAMETERS\n\n\(parameters)")
                        
                        let decodedStr = NSString(data: (responseObject as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)
                        
                        print_debug(object: "\n\nRECEIVED DATA BEFORE PARSING IS \n\n\n\(String(describing: decodedStr))")
                        
                        let json: AnyObject? = try? JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        if let jsonDict = json as? [AnyObject] {
                            
                            print_debug(object: "\n\nRECEIVED DATA AFTER PARSING IS \n\n\n\(jsonDict)")
                            successBlock(jsonDict)
                            
                        } else {
                            
                            let errorUserInfo =
                                [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
                                    NSURLErrorFailingURLErrorKey : "\(URLString)"
                            ]
                            
                            let jsonError =  NSError(domain: NSCocoaErrorDomain, code: -101, userInfo:errorUserInfo)
                            
                            failureBlock(jsonError)
                        }
                        
        }) { (operation, error) -> Void in
            
            //CommonClass.stopLoader()
            print_debug(object: "\n\n\n------------------HITTING URL\n\n \(URLString)\n\n\n-----------------WITH GET PARAMETERS\n\n\(parameters)")
            failureBlock(error! as NSError)
        }
    }
    
    //MARK:- To create a user & login User
    class  func PUTWITHJSON_CUSTOM(URLString: String!, parameters: [String : AnyObject], successBlock: @escaping webServiceWithHeaderSuccess, failureBlock: @escaping webServiceFailure) {
        
        if !GSNetworking.isConnectedToNetwork {
            
            let errorUserInfo =
                [   NSLocalizedDescriptionKey : NO_INTERNET_MSG,
                    NSURLErrorFailingURLErrorKey : "\(URLString) "
            ]
            
            let noInternetError =  NSError(domain: NSCocoaErrorDomain, code: NO_INTERNET_ERROR_CODE, userInfo:errorUserInfo)
            
            //CommonClass.showAlertText("Internet Not Available")
            
            failureBlock(noInternetError)
            
            return
        }
        
        let manager = AFHTTPRequestOperationManager()
        
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH PUT PARAMETERS\n\n\(parameters)\n\n\n")
        
        if let authCookieAddress = UserDefaults.getStringVal(key: NSUserDefaultKeys.COOKIEADDRESS) {
            print_debug(object: "Auth")
            print_debug(object: "x-bbsc : \(authCookieAddress)" )
            manager.requestSerializer.setValue(authCookieAddress, forHTTPHeaderField: "x-bbsc")
        } else {
            print_debug(object: "Guest")
            print_debug(object: "x-bbsc : \(GUEST_COOKIE_ADDRESS)" )
            manager.requestSerializer.setValue(GUEST_COOKIE_ADDRESS, forHTTPHeaderField: "x-bbsc")
            
        }
        print_debug(object: "\n\n\n--------------------HITTING HEADER\n\n \(manager.requestSerializer.httpRequestHeaders)")
        
        manager.put(URLString, parameters: parameters, success: { (operation, response) in
            
            let decodedStr = NSString(data: (response as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)
            
            print_debug(object: "\n\nRECEIVED DATA BEFORE PARSING IS")
            print_debug(object: "--------------------------------- \(String(describing: decodedStr))")
            
            let json: AnyObject? = try? JSONSerialization.jsonObject(with: (response as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            
            if let resonponseData = json {
                
                if let responseHeader = operation?.response.allHeaderFields as? [ String : AnyObject] {
                    var finalResponseHeader = responseHeader
                    //var finalResponseHeader = [String: AnyObject]()
                    finalResponseHeader["status"] = operation?.response.statusCode as AnyObject
                    
                    print_debug(object: "\n\nRECEIVED HEADER RESPONSE")
                    print_debug(object: "--------------------------------- \n\n\n\(finalResponseHeader)")
                    
                    successBlock(finalResponseHeader, resonponseData)
                    
                }
                
            } else {
                
                let errorUserInfo =
                    [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
                        NSURLErrorFailingURLErrorKey : "\(URLString)"
                ]
                
                let jsonError =  NSError(domain: NSCocoaErrorDomain, code: -101, userInfo:errorUserInfo)
                
                failureBlock(jsonError)
                
            }
            
        }) { (operation, error) in
            
            print_debug(object: "\n\n\n------------------HITTING URL\n\n \(URLString)\n\n\n-----------------WITH PUT PARAMETERS\n\n\(parameters)")
            
            failureBlock(error! as NSError)
        }
        
    }
    
    class func POSTWITHJSON_CUSTOM(isJSONReq: Bool, URLString: String!, parameters: [String : AnyObject], successBlock: @escaping webServiceWithHeaderSuccess, failureBlock: @escaping webServiceFailure) {
        
        let url = URLString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !GSNetworking.isConnectedToNetwork {
            
            let errorUserInfo =
                [   NSLocalizedDescriptionKey : NO_INTERNET_MSG,
                    NSURLErrorFailingURLErrorKey : "\(URLString)"
            ]
            
            let noInternetError =  NSError(domain: NSCocoaErrorDomain, code: NO_INTERNET_ERROR_CODE, userInfo:errorUserInfo)
            
            //CommonClass.showAlertText("Internet Not Available")
            
            failureBlock(noInternetError)
            
            return
        }
        
         print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH GET PARAMETERS\n\n\(parameters)")
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        if isJSONReq {
            manager.requestSerializer = AFJSONRequestSerializer()
            manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else {
            
            manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            manager.requestSerializer = AFHTTPRequestSerializer()
        }
        
        if let authCookieAddress = UserDefaults.getStringVal(key: NSUserDefaultKeys.COOKIEADDRESS) {
            print_debug(object: "Auth")
            print_debug(object: "x-bbsc : \(authCookieAddress)" )
            manager.requestSerializer.setValue(authCookieAddress, forHTTPHeaderField: "x-bbsc")
        } else {
            print_debug(object: "Guest")
            print_debug(object: "x-bbsc : \(GUEST_COOKIE_ADDRESS)" )
            manager.requestSerializer.setValue(GUEST_COOKIE_ADDRESS, forHTTPHeaderField: "x-bbsc")
        }
        
        
        print_debug(object: manager.requestSerializer.httpRequestHeaders.description)
        
        
        print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH POST PARAMETERS\n\n\(parameters)\n\n\n")
        
        manager.post(url, parameters: parameters, success: { (operation, response) in
            
            let decodedStr = NSString(data: (response as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)
            
            print_debug(object: "\n\nRECEIVED DATA BEFORE PARSING IS")
            print_debug(object: "--------------------------------- \(String(describing: decodedStr))")
            
            let json: AnyObject? = try? JSONSerialization.jsonObject(with: (response as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            
            
            if let resonponseData = json {
                
                if let responseHeader = operation?.response.allHeaderFields as? [ String : AnyObject] {
                    var finalResponseHeader = responseHeader
                    finalResponseHeader["status"] = operation?.response.statusCode as AnyObject
                    
                    print_debug(object: "\n\nRECEIVED HEADER RESPONSE")
                    print_debug(object: "--------------------------------- \n\n\n\(finalResponseHeader)")
                    
                    successBlock(finalResponseHeader, resonponseData)
                    
                }
                
            } else {
                
                let errorUserInfo =
                    [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
                        NSURLErrorFailingURLErrorKey : "\(URLString)"
                ]
                
                let jsonError =  NSError(domain: NSCocoaErrorDomain, code: -101, userInfo:errorUserInfo)
                
                failureBlock(jsonError)
                
            }
        }) { (operation, error) in
            
            print_debug(object: "\n\n\n------------------HITTING URL\n\n \(URLString)\n\n\n-----------------WITH POST PARAMETERS\n\n\(parameters)")
            
            failureBlock(error! as NSError)
        }
        
    }
    
    //GET response with header
    class func GETWITH_CUSTOM(URLString: String!, parameters: AnyObject!, successBlock: @escaping webServiceWithHeaderSuccess, failureBlock: @escaping webServiceFailure) {
        
        
        if !GSNetworking.isConnectedToNetwork {
            
            let errorUserInfo =
                [   NSLocalizedDescriptionKey : NO_INTERNET_MSG,
                    NSURLErrorFailingURLErrorKey : "\(URLString)"
            ]
            
            let noInternetError =  NSError(domain: NSCocoaErrorDomain, code: NO_INTERNET_ERROR_CODE, userInfo:errorUserInfo)
            
            //CommonClass.showAlertText("Internet Not Available")
            
            failureBlock(noInternetError)
            
            return
        }
        
         print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH GET PARAMETERS\n\n\(parameters)")
        
        let manager = AFHTTPRequestOperationManager()
        
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.requestSerializer = AFHTTPRequestSerializer()
        
        //manager.requestSerializer.setValue(api_key, forHTTPHeaderField: "api-key")
        
        if let authCookieAddress = UserDefaults.getStringVal(key: NSUserDefaultKeys.COOKIEADDRESS) {
            print_debug(object: "Auth")
            print_debug(object: "x-bbsc : \(authCookieAddress)" )
            manager.requestSerializer.setValue(authCookieAddress, forHTTPHeaderField: "x-bbsc")
        } else {
            print_debug(object: "Guest")
            print_debug(object: "x-bbsc : \(GUEST_COOKIE_ADDRESS)" )
            manager.requestSerializer.setValue(GUEST_COOKIE_ADDRESS, forHTTPHeaderField: "x-bbsc")
        }
        
        manager.get(URLString, parameters: parameters, success: { (operation, responseObject) -> Void in
            
            //CommonClass.stopLoader()
            
            print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH GET PARAMETERS\n\n\(parameters)")
            
            let decodedStr = NSString(data: (responseObject as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)
            
            print_debug(object: "\n\nRECEIVED DATA BEFORE PARSING IS \n\n\n\(String(describing: decodedStr))")
            
            let json: AnyObject? = try? JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            
            if let resonponseData = json {
                
                if (operation?.response.allHeaderFields as? [ String : AnyObject]) != nil {
                    //var finalResponseHeader = responseHeader
                    var finalResponseHeader = [String: AnyObject]()
                    finalResponseHeader["status"] = operation?.response.statusCode as AnyObject
                    
                    print_debug(object: "\n\nRECEIVED HEADER RESPONSE")
                    print_debug(object: "--------------------------------- \n\n\n\(finalResponseHeader)")
                    
                    successBlock(finalResponseHeader, resonponseData)
                    
                }
                
            } else {
                
                let errorUserInfo =
                    [   NSLocalizedDescriptionKey : "Error In Parsing JSON",
                        NSURLErrorFailingURLErrorKey : "\(URLString)"
                ]
                
                let jsonError =  NSError(domain: NSCocoaErrorDomain, code: -101, userInfo:errorUserInfo)
                
                failureBlock(jsonError)
                
            }
            
        }) { (operation, error) -> Void in
            
            //CommonClass.stopLoader()
            print_debug(object: "\n\n\n------------------HITTING URL\n\n \(URLString)\n\n\n-----------------WITH GET PARAMETERS\n\n\(parameters)")
            failureBlock(error! as NSError)
        }
    }
    
    //Put with upload image.
    class func PUT_UPLOAD_IMAGE(URLString: String!, parameters: JSONDictionary,image: UIImage? ,successBlock: @escaping webServiceSuccess  , failureBlock: @escaping webServiceFailure) {
         print_debug(object: "\n\n\n--------------------HITTING URL\n\n \(URLString)\n\n\n--------------------WITH GET PARAMETERS\n\n\(parameters)")
        
        if !GSNetworking.isConnectedToNetwork {
            
            let errorUserInfo =
                [   NSLocalizedDescriptionKey : NO_INTERNET_MSG,
                    NSURLErrorFailingURLErrorKey : "\(URLString)"
            ]
            
            let noInternetError =  NSError(domain: NSCocoaErrorDomain, code: NO_INTERNET_ERROR_CODE, userInfo:errorUserInfo)
            
            //CommonClass.showAlertText("Internet Not Available")
            
            failureBlock(noInternetError)
            
            return
        }
        
        let sessionManager: AFHTTPSessionManager = AFHTTPSessionManager()
        sessionManager.responseSerializer = AFHTTPResponseSerializer()
        sessionManager.requestSerializer = AFHTTPRequestSerializer()
        sessionManager.requestSerializer.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        
        if let authCookieAddress = UserDefaults.getStringVal(key: NSUserDefaultKeys.COOKIEADDRESS) {
            print_debug(object: "Auth")
            print_debug(object: "x-bbsc : \(authCookieAddress)" )
            //manager.requestSerializer.setValue(authCookieAddress, forHTTPHeaderField: "x-bbsc")
            sessionManager.requestSerializer.setValue(authCookieAddress, forHTTPHeaderField: "x-bbsc")
        }
        
        
        print_debug(object: "\n\n\n------------------HITTING URL\n\n \(URLString)\n\n\n-----------------WITH GET PARAMETERS\n\n\(parameters)")
        
        guard let img = image else { return }
        
        do {
            let request: NSMutableURLRequest = try sessionManager.requestSerializer.multipartFormRequest(withMethod: "PUT", urlString: URLString, parameters: parameters, constructingBodyWith: { (formData: AFMultipartFormData!) in
                
                formData.appendPart(withFileData: UIImageJPEGRepresentation(img, 0.7), name: "image", fileName: "photo.jpg", mimeType: "image.jped")
                
            }, error: ())
            
            sessionManager.dataTask(with: request as URLRequest!) { (response, responseObject, error) -> Void in
                
                if((error == nil)) {
                    print_debug(object: responseObject)
                    
                    let json: AnyObject? = try? JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    
                    
                    if let resonponseData = json as? [String: AnyObject] {
                        successBlock(resonponseData)
                    }
                }
                else {
                    print_debug(object: error)
                    print_debug(object: "\n\n\n------------------HITTING URL\n\n \(URLString)\n\n\n-----------------WITH GET PARAMETERS\n\n\(parameters)")
                    failureBlock(error! as NSError)
                }
                }.resume()
            
        } catch {
            
            
            print_debug(object: "faild in catch...")
            
        }
        
        
    }
    
    
    class var isConnectedToNetwork : Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection) ? true : false
        
    }
    
 }
