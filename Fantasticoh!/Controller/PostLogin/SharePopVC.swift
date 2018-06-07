//
//  SharePopVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 10/11/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

protocol shareDelegate : class {
    func shareData()
}
class SharePopVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var fantasticohLabel: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    weak var delegate: shareDelegate?
    var shrarePostName = ""
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fantasticohLabel.text = "Whould you like to share?\n" + shrarePostName
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- IBAction, Selector & Private method's
    //MARK:-
    
    @IBAction func shareBtnTap(_ sender: Any) {
        if let dele = self.delegate {
            dele.shareData()
        }
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
    
    @IBAction func cancelBtnTap(_ sender: Any) {
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
    
    
}
