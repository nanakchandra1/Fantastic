//
//  OnlyFanVC.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 02/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit

enum VcState {
    
    case None, Personal, Channel, OtherProfile
}

class OnlyFanVC: UIViewController {

    
    var fansVC:FansVC!
    var vCState: VCState!
    var channelId:String = ""
    var userName:String = ""
    
    weak var delegate: TabBarDelegate!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var fanDataLabel: UILabel!
    
    @IBOutlet weak var containerViewForFanVC: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backButton.setImage(#imageLiteral(resourceName: "nav_back"), for: .normal)
        self.fanDataLabel.text = "Fan--\(userName)"
       
        initialSetup()
        
        
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)

    }
    
    func initialSetup(){
        fansVC = self.storyboard!.instantiateViewController(withIdentifier:"FansVC") as! FansVC
        if let dele = self.delegate {
            fansVC.tabBarDelegate = dele
        }
      
        fansVC.vCState   = VCState.Channel
        fansVC.channelId = channelId
        
        //*******************************************
        //=====================
        let navigationController = SHARED_APP_DELEGATE.window?.rootViewController
        print_debug(object: navigationController)
        fansVC.temExploreVC = navigationController
        fansVC.view.frame = self.containerViewForFanVC.bounds
        self.containerViewForFanVC.addSubview(fansVC.view)
        self.addChildViewController(fansVC)
        fansVC.didMove(toParentViewController: self)
        
    }
    
}
