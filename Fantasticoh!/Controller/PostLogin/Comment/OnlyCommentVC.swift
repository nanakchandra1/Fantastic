//
//  OnlyCommentVC.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 02/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit

class OnlyCommentVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    var channelId = ""
    var chatVC:CommentVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    self.backButton.setImage(#imageLiteral(resourceName: "nav_back"), for: .normal)
      initialSetup()
       
    }

    @IBAction func backBtnAction(_ sender: UIButton) {
       
        self.navigationController?.popViewController(animated: true)
        
        
    }
    func initialSetup(){
       
        chatVC = self.storyboard!.instantiateViewController(withIdentifier:"CommentVC") as! CommentVC
        chatVC.channelId = self.channelId
        chatVC.view.frame = self.containerView.bounds
        chatVC.willMove(toParentViewController: self)
        self.containerView.addSubview(chatVC.view)
        self.addChildViewController(chatVC)
        chatVC.didMove(toParentViewController: self)
        
        
    }

}
