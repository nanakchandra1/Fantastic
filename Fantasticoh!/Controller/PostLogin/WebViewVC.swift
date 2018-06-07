//
//  WebViewVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 22/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class WebViewVC: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var readMoreButton: UIButton!
    var urlString = ""
    var text = ""
    @IBOutlet weak var wView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wView.delegate = self
        
        CommonFunctions.showLoader()
        if !urlString.isEmpty {
            let url = URL(string: urlString)
           let request = URLRequest(url: url!)
            self.wView.loadRequest(request)
        } else {
            
            let htmlStr = "<html><body><p>\(text)</p></body></html>"
            
            self.wView.loadHTMLString(htmlStr, baseURL: nil)
            
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        CommonFunctions.hideLoader()
    }
    
    @IBAction func doneBtnTap(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func readMoreBtnTap(_ sender: Any) {
        
        if let url = URL(string: urlString) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(url): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(url): \(success)")
            }
        }
    }
}
