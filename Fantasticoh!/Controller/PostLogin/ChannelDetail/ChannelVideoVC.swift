//
//  ChannelVideoVC.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 03/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit

class ChannelVideoVC: UIViewController,PushController {
    func pushHandleForTrending(indexPath: IndexPath, videos: [AnyObject]) { //Optional protocol
        
    }
    

    @IBOutlet weak var channelVideoTableView: UITableView!
    
    var videosData = [ChannelPhotosAndVideos]()
    var channelId:String = ""
    var avtarUrl:String = ""
    var channelName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelVideoTableView.delegate = self
        channelVideoTableView.dataSource = self
        
        channelVideoTableView.estimatedRowHeight = 500
        let video = UINib(nibName: "ChannelVideoTableViewCell", bundle: nil)
        channelVideoTableView.register(video, forCellReuseIdentifier: "ChannelVideoTableViewCell")
    }
    
    
    func pushHandleController(indexPath: IndexPath,videos:[ChannelPhotosAndVideos]) {
     
           let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
           vc.beepVCState = BeepVCState.AllTagVCState
           vc.hasTags = videosData[indexPath.section].hashtags
        
           vc.beepData =  videos[indexPath.section].beeps[indexPath.row] as AnyObject
           vc.from = indexPath.row
         // self.currentRow = indexPath.row
         self.navigationController?.pushViewController(vc, animated: true)
        
    }
}


extension ChannelVideoVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return videosData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell =  channelVideoTableView.dequeueReusableCell(withIdentifier: "ChannelVideoTableViewCell", for: indexPath) as? ChannelVideoTableViewCell  else{
            fatalError("Cell not found")
            
        }
        cell.headerLabel.text = videosData[indexPath.row].tagDisplay.uppercased()
        cell.pushControllerdelegate = self
        cell.videos = [videosData[indexPath.row]]
        
        
        cell.bottomBtn.addTarget(self, action: #selector(seeBtnTapped), for: .touchUpInside)
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    
   
    
    func seeBtnTapped(sender:UIButton){
        
        guard let indexPath = sender.tableViewIndexPath(tableView: channelVideoTableView) else{
            
            fatalError("Not found cell")
        }
        
       let allVideo = self.storyboard!.instantiateViewController(withIdentifier:"AllVideosVC") as! AllVideosVC
       
        
        allVideo.includeNonGraphBeeps  = videosData[indexPath.row].includeNonGraphBeeps
        allVideo.hashTags = videosData[indexPath.row].hashtags
        allVideo.tagsDisplay = videosData[indexPath.row].tagDisplay
        allVideo.channelId  = self.channelId
        allVideo.avtarUrl = self.avtarUrl
        allVideo.channelName = self.channelName
        self.navigationController?.pushViewController(allVideo, animated: true)
    
    }
    
}
