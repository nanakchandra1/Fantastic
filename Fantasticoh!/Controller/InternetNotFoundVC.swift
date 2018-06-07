//
//  InternetNotFoundVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 01/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class InternetNotFoundVC: UIViewController , UIAlertViewDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       _ = CommonFunctions.showAlert(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", btnLbl: "OK")
        
        let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
//            exit(0)
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)

            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
