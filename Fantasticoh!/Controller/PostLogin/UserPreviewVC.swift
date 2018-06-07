//
//  UserPreviewVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 08/08/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit


protocol UserPreviewVCDelegate {
    func showUserDetail(index : Int)
    func showUserChat(index : Int)
    
}

class UserPreviewVC: UIViewController {

    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    
    
    var userName = ""
    var userImgUrl = ""
    var index = 0
    
    var UserPreviewVCDelegate: UserPreviewVCDelegate!

    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.imageView.layer.cornerRadius = self.imageView.frame.height/2
        self.imageView.clipsToBounds = true
        self.lbl.text = userName
        
        if userImgUrl.isEmpty {
            self.imageView.image = PROFILEPLACEHOLDER
        } else {
            self.imageView.sd_setImage(with: URL(string: userImgUrl), placeholderImage: PROFILEPLACEHOLDER)
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        
        let action1 = UIPreviewAction(title: "User Detial", style: .default, handler: { previewAction, viewController in
            print_debug(object: "Action One Selected")
            
            if let dele = self.UserPreviewVCDelegate {
                dele.showUserDetail(index: self.index)
            }
        })
        
        let action2 = UIPreviewAction(title: "Chat", style: .default, handler: { previewAction, viewController in
            
            if let dele = self.UserPreviewVCDelegate {
                dele.showUserChat(index: self.index)
            }
        })
        
        let action3 = UIPreviewAction(title: "Cancel", style: .default, handler: { previewAction, viewController in
            
        })
        
        
        return [action1, action2, action3]
    }

}
