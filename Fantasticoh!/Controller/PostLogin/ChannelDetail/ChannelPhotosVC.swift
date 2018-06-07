//
//  ChannelPhotosVC.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 03/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit

class ChannelPhotosVC: UIViewController,PushController {
   
    
    
    
    //MARK:- IBOUTLETS
    //================
    
    
    @IBOutlet weak var photosTableView: UITableView!
    //MARK:- VARIABLES
    //================
    
    var channelId :String =  ""
    var userName = ""
    var photoData = [ChannelPhotosAndVideos]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FB_AD = false // for activating the ads
        photosTableView.delegate = self
        photosTableView.dataSource = self
        
        let photoTableView = UINib(nibName: "ChannelPhotosTableViewCell", bundle: nil)
        photosTableView.register(photoTableView, forCellReuseIdentifier: "ChannelPhotosTableViewCell")
        self.photosTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func pushHandleForTrending(indexPath: IndexPath, videos: [AnyObject]) {  //Optional
        
    }
    
    func pushHandleController(indexPath: IndexPath,videos:[ChannelPhotosAndVideos]) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
        vc.beepVCState = BeepVCState.AllTagVCState
        vc.hasTags = photoData[indexPath.section].hashtags
        
        vc.beepData =  videos[indexPath.section].beeps[indexPath.row] as AnyObject
        vc.from = indexPath.row
        // self.currentRow = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


extension ChannelPhotosVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell =  photosTableView.dequeueReusableCell(withIdentifier: "ChannelPhotosTableViewCell", for: indexPath) as? ChannelPhotosTableViewCell  else{
            fatalError("Cell not found")
            
        }
        
        cell.headerLabel.text = photoData[indexPath.row].tagDisplay.uppercased()
        cell.photos = [photoData[indexPath.row]]
        cell.bottomBtn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        cell.pushControldelegate = self
        
        //cell.bottomBtn.addTarget(self, action: #selector(seeButtonTapped(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func buttonTapped(sender:UIButton){
        
        guard let indexPath = sender.tableViewIndexPath(tableView: photosTableView) else{
            
            fatalError("Not found cell")
        }
        
            let allPhoto = self.storyboard!.instantiateViewController(withIdentifier:"AllPhotosVC") as! AllPhotosVC
            allPhoto.includeNonGraphBeeps  = photoData[indexPath.row].includeNonGraphBeeps
            allPhoto.hashTags = photoData[indexPath.row].hashtags
            allPhoto.tagsDisplay = photoData[indexPath.row].tagDisplay
         allPhoto.name = self.userName
            allPhoto.channelId  = self.channelId
            self.navigationController?.pushViewController(allPhoto, animated: true)
            
        }
    }

/*
 if let img2xW = imgURLs["img2xW"] as? Int {
 let ratio = (CGFloat(img2xH)/CGFloat(img2xW)) * (SCREEN_WIDTH)
 if ratio <= 180 {
 cell.imageView.contentMode = .scaleToFill //240
 } else {
 //return ratio
 if ratio.isNaN {
 cell.imageView.contentMode = .scaleToFill
 } else {
 cell.imageView.contentMode = .scaleAspectFill
 }*/
