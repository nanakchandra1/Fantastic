//
//  WebServiceController.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 10/08/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

//TO DO : Channel releated three image.
import Foundation

internal typealias customSuccessClosure = (_ success : Bool, _ data: [AnyObject]?) -> Void

internal typealias  webServiceWithHeaderSuccess = (_ sucess: Bool, _ DataHeaderResponse : [String : AnyObject]?, _ DataResultResponse : [String : AnyObject]?) -> Void

internal typealias  webServiceGetJSONArraySuccess = (_ sucess: Bool, _ errorMessage: String, _ data : [AnyObject]?) -> Void

internal typealias successClosure = (_ success : Bool, _ errorMessage: String, _ data: [String: AnyObject]?) -> Void

internal typealias spotLightClosure = (_ success : Bool, _ data: Data?) -> Void

final class WebServiceController {
    
    //MARK:- Get Country List
    //TODO : check webservice...............
    class func getCountryList(parameters:[String:AnyObject],webServiceSuccess: @escaping customSuccessClosure) {
        
        GSNetworking.GET_CUSTOM(URLString: WS_CountryListURL, parameters: parameters as AnyObject, successBlock: { (JSON) in
            
            webServiceSuccess(true, JSON)
            
        }) { (error) in
            
            webServiceSuccess(false, nil)
        }
    }
    
    //MARK:- Create a user & login User
    class func loginService(parameters:[String : AnyObject],webServiceSuccess: @escaping webServiceWithHeaderSuccess) {
        
        GSNetworking.PUTWITHJSON_CUSTOM(URLString: WS_UserURL, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, JSONHeaderResponse, jsonDict)
                    } else {
                        print_debug(object: "Response code other than 200.")
                        webServiceSuccess(false, nil, nil)
                    }
                } else {
                    print_debug(object: "Faild to get data.")
                    webServiceSuccess(false, nil, nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, nil, nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, nil, nil)
        }
    }
    
    //MARK:- Updateuser detail's
    //TODO : check webservice...............
    class func updateUserService(parameters:[String : AnyObject], userId: String,webServiceSuccess: @escaping webServiceWithHeaderSuccess) {
        
        let url = WS_UserURL + "/\(userId)"
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, JSONHeaderResponse, jsonDict)
                    } else {
                        webServiceSuccess(false, nil, nil)
                    }
                } else {
                    webServiceSuccess(false, nil, nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, nil, nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, nil, nil)
        }
    }
    
    //MARK:- Update user profile image
    //TODO : check webservice...............
    class func updateUserProfileImage(url: String, image: UIImage, userId: String,webServiceSuccess: @escaping webServiceWithHeaderSuccess) {
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: [String: AnyObject](), successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, JSONHeaderResponse, jsonDict)
                    } else {
                        webServiceSuccess(false, nil, nil)
                    }
                } else {
                    webServiceSuccess(false, nil, nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, nil, nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, nil, nil)
        }
    }
    
    //MARK:- Get Feeds.
    /*class func getDashboradFeedService(parameters:[String:AnyObject],webServiceSuccess: customSuccessClosure) {
        
        GSNetworking.GET_CUSTOM(WS_Dashboard, parameters: parameters, successBlock: { (JSON) in
            
            webServiceSuccess(success: true, data: JSON)
            
        }) { (error) in
            
            webServiceSuccess(success: false, data: nil)
        }
    }
    
    */
    
    /*
    //MARK:- SearchChannels
    class func searchChannelsService(parameters:[String:AnyObject],webServiceSuccess: customSuccessClosure)  {
        
        GSNetworking.GET_CUSTOM(WS_SearchChannel, parameters: [String:AnyObject](), successBlock: { (JSON) in
            
            webServiceSuccess(success: true, data: JSON)
            
        }) { (error) in
            
            webServiceSuccess(success: false, data: nil)
        }
    } */
    
    //MARK:- SearchChannels
    class func searchChannelsService(url: String,webServiceSuccess: @escaping customSuccessClosure) {
        
        GSNetworking.GET_CUSTOM(URLString: url, parameters: [String:AnyObject]() as AnyObject, successBlock: { (JSON) in
            
            webServiceSuccess(true, JSON)
            
        }) { (error) in
            
            webServiceSuccess(false, nil)
        }
    }
    
    
    //let WS_FeatureChannelList
    
    //WEBservice start---------------------
    //===================================================================
    
    //MARK:- Get Feeds.
    class func getDashboradFeed(url: String, parameters:[String:AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                print_debug(object: JSONResultResponse)
                print_debug(object: "Header")

                print_debug(object: JSONHeaderResponse)

                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }

    }
    
    //MARK:- Feature Channel List
    class func getFeatureChannelList(parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: WS_FeatureChannelList, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess get data.", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }

    }
    
    //MARK:- Trending Channel List
    class func getTrendingChannelList(parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: WS_TrendingChannelList, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess get data.", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
    
    
    
    //MARK:- Follow/Unfollow channel
    class func follwUnfollowChannel(parameters:[String:AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: WS_FollowChannel, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing in \"follwUnfollowChannel\"")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Faild to get data", nil)
        }
    }
    
    //MARK:- Get mini channel detail mini
    class func getMiniChannelDetail(channelId: String, webServiceSuccess: @escaping successClosure) {
        
        let url = WS_Channel + "/" + channelId + "/" + "mini"
        print_debug(object: url)
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: [String:AnyObject]() as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess get data.", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    //MARK:- Get channel followers(Fan)
    class func getChannelFollowers(url: String, webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        
        print_debug(object: url)
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: [String:AnyObject]() as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }

    }
    
    //MARK:- like & share beep
    class func beep_Share_Like(url: String, parameters:[String : AnyObject], webServiceSuccess: @escaping webServiceWithHeaderSuccess) {
        
        print_debug(object: url)
        print_debug(object: parameters)
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
          
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, JSONHeaderResponse, jsonDict)
                    } else {
                        webServiceSuccess(false, nil, nil)
                    }
                } else {
                    webServiceSuccess(false, nil, nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, nil, nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, nil, nil)
        }
    }
    
    //MARK:- Get Releated beep's
    class func getReleatedBeep(parameters:[String : AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: WS_ReleatedBeep, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        //webServiceSuccess(success: true, errorMessage: "Sucess get data.", data: jsonDict)
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        //webServiceSuccess(success: false, errorMessage: "Response code other than 200.", data: nil)
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    //webServiceSuccess(success: false, errorMessage: "Faild to get data.", data: nil)
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                //webServiceSuccess(success: false, errorMessage: "Response can't Parsing.", data: nil)
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
    
    //MARK:- Get Channel list follow by user
    class func getUserFollowChannels(url: String, param: [String: AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: param as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    
    //MARK:- Get user detail
    class func getUserDetail(userID: String, webServiceSuccess: @escaping successClosure) {
        
        let url = WS_UserChannelList + "/" + userID
        print_debug(object: url)
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: [String:AnyObject]() as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess get data.", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    //MARK:- Get no of user whose like beep
    class func getListOfLikeUser(url: String, param: [String: AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: param as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    
    //MARK:- Get releated channels
    class func getReleatedChannelsList(parameters:[String : AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: WS_ReleatedChannelList, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
    
    //MARK:- Get Channel chat
    class func getChannelsChat(url: String, parameters:[String : AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
    
    
    //MARK:- Channel chat send
    class func sendChat(parameters:[String : AnyObject],webServiceSuccess: @escaping webServiceWithHeaderSuccess) {
        
        GSNetworking.PUTWITHJSON_CUSTOM(URLString: WS_ChannelChatSend, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, JSONHeaderResponse, jsonDict)
                    } else {
                        webServiceSuccess(false, nil, nil)
                    }
                } else {
                    webServiceSuccess(false, nil, nil)
                }
                
            } else {
            
                webServiceSuccess(false, nil, nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, nil, nil)
        }
    }
    
    //MARK:- BeepDetail
    //class func (url: String, parameters:[String:AnyObject], webServiceSuccess: webServiceGetJSONArraySuccess)
    
    class func getBeepDetail(url: String, parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess get data.", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    
    //MARK:- like & share beep
    class func Like_Chat_Message(url: String, parameters:[String : AnyObject], webServiceSuccess: @escaping webServiceWithHeaderSuccess) {
        
        print_debug(object: url)
        print_debug(object: parameters)
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, JSONHeaderResponse, jsonDict)
                    } else {
                        webServiceSuccess(false, nil, nil)
                    }
                } else {
                    webServiceSuccess(false, nil, nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, nil, nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, nil, nil)
        }
    }
    
    
    class  func uploadUserImage(url: String, parameters: [String : AnyObject],img: UIImage, webServiceSuccess: @escaping webServiceWithHeaderSuccess){
        
        
        
        GSNetworking.PUT_UPLOAD_IMAGE(URLString: url, parameters: parameters, image: img, successBlock: { (response: [String: AnyObject]) in
            
                print_debug(object: response)
            
                webServiceSuccess(true, nil, response)
            
            }) { (error) in
                print_debug(object: error)
                webServiceSuccess(false, nil, nil)
        }
    
    }
    
    //MARK:- Get UserChat
    class func getUserChat(url: String, parameters: [String:AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {

        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get chat data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }

    
    //MARK:- Send message
    class func sendPersonalMsg(parameters:[String : AnyObject],webServiceSuccess: @escaping webServiceWithHeaderSuccess) {
        
        print_debug(object: WS_UserMsgSend)
        print_debug(object: parameters)
        
        GSNetworking.PUTWITHJSON_CUSTOM(URLString: WS_UserMsgSend, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, JSONHeaderResponse, jsonDict)
                    } else {
                        print_debug(object: "Response code other than 200.")
                        webServiceSuccess(false, nil, nil)
                    }
                } else {
                    print_debug(object: "Faild to get data.")
                    webServiceSuccess(false, nil, nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, nil, nil)
            }
            
        }) { (error) in
            
        
            print_debug(object: error)
            webServiceSuccess(false, nil, nil)
        }
    }
    
    
    //MARK:- Get UserChat
    class func getUserChatList(url: String, parameters: [String:AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        print_debug(object: url)
        print_debug(object: parameters)
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get chat data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
 
    
    
    //MARK:- SearchEveryThing API
    class func searchEveryThing(url: String, parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [String : AnyObject] {
                
                print_debug(object: JSONResultResponse)
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
    
    
    //MARK:- BeepKeyword sugessions
    class func beepsKeywordSugession(url: String, parameters: [String:AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        print_debug(object: url)
        print_debug(object: parameters)
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get chat data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
    
    class func getSpotLightSearchList(url: String,webServiceSuccess: @escaping customSuccessClosure) {
        
        GSNetworking.GET_CUSTOM(URLString: url, parameters: [String:AnyObject]() as AnyObject, successBlock: { (JSON) in
            print_debug(object: JSON)
            webServiceSuccess(true, JSON)
            
        }) { (error) in
            print_debug(object: error.description)
            webServiceSuccess(false, nil)
        }
    }
    
    
    //MARK:- Get unread msg count
    class func getUnreadMessageCount(webServiceSuccess: @escaping successClosure) {
        
        
        GSNetworking.GETWITH_CUSTOM(URLString: WS_UserMsgUnreadCount, parameters: [String:AnyObject]() as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                webServiceSuccess(true, "Sucess get data.", jsonDict)
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    //MARK:- BeepKeyword sugessions
    class func markChatRead(url: String, parameters: [String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        print_debug(object: url)
        print_debug(object: parameters)
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject]  {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get chat data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
    
    
    
    //MARK:- Follow/Unfollow channel
    class func ReportUser(url: String,parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                       webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Response code other than 200.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing in \"follwUnfollowChannel\"")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    //MARK:- Update UserPushToken
    class func updatePushToken(url: String,parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Response code other than 200.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing in \"follwUnfollowChannel\"")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    //MARK:- Follow/Unfollow channel
    class func ReportBeep(url: String,parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Response code other than 200.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing in \"follwUnfollowChannel\"")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    //MARK:- Follow/Unfollow channel
    class func ReportComment(url: String,parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Response code other than 200.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing in \"follwUnfollowChannel\"")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    //MARK:- Follow/Unfollow channel
    class func blockUser(url: String,parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Response code other than 200.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing in \"follwUnfollowChannel\"")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    
    
    //MARK:- Login Session channel
    class func loginSession( webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: WS_LoginUserSession, parameters: [String:AnyObject](), successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Response code other than 200.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing in \"follwUnfollowChannel\"")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    //MARK:- View Beep
    class func viewBeep(url: String,parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Response code other than 200.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing in \"follwUnfollowChannel\"")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    //MARK:- View Channel
    class func viewChannel(url: String,parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Response code other than 200.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing in \"follwUnfollowChannel\"")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    //MARK:- GET CHANNEL DETAILS //Arvind
    //===================================

    class func channelDetail(url: String,parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: url, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess get data.", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
    
    
    //MARK:- GET PHOTOS DATA //***ARVIND***//
   //=======================================
    
    class func gettingChannelPhotos(parameters:[String:AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: WS_PhotosVideos, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
    
    //MARK:- SeeALL Data //***ARVIND***//
    //=======================================
    
    class func seeAllChannelPhotosAndVideos(parameters:[String:AnyObject], webServiceSuccess: @escaping webServiceGetJSONArraySuccess) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: WS_AllChannels, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
    
    //MARK:- View User
    class func viewUser(url: String,parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: url, parameters: parameters, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            
            print_debug(object: JSONResultResponse)
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess", jsonDict)
                        
                        
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Response code other than 200.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing in \"follwUnfollowChannel\"")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
    }
    
    
    class func userSession( webServiceSuccess: @escaping webServiceWithHeaderSuccess) {
    
        
        GSNetworking.POSTWITHJSON_CUSTOM(isJSONReq: true, URLString: WS_LoginSession, parameters: [:], successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, JSONHeaderResponse, jsonDict)
                    } else {
                        webServiceSuccess(false, nil, nil)
                    }
                } else {
                    webServiceSuccess(false, nil, nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, nil, nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, nil, nil)
        }
    }
    
    //MARK:- New Feature Channel List
    class func getNewFeatureChannelList(parameters:[String:AnyObject], webServiceSuccess: @escaping successClosure) {
        
        GSNetworking.GETWITH_CUSTOM(URLString: WS_FeatureChannelList, parameters: parameters as AnyObject, successBlock: { (JSONHeaderResponse, JSONResultResponse) in
            
            if let jsonDict = JSONResultResponse as? [String: AnyObject] {
                
                if let statusCode = JSONHeaderResponse["status"]?.int64Value {
                    if statusCode == 200 {
                        webServiceSuccess(true, "Sucess get data.", jsonDict)
                    } else {
                        webServiceSuccess(false, "Response code other than 200.", nil)
                    }
                } else {
                    webServiceSuccess(false, "Faild to get data.", nil)
                }
                
            } else {
                
                print_debug(object: "Response can't Parsing.")
                webServiceSuccess(false, "Response can't Parsing.", nil)
            }
            
        }) { (error) in
            
            print_debug(object: error)
            webServiceSuccess(false, "Error in webservice.", nil)
        }
        
    }
}
