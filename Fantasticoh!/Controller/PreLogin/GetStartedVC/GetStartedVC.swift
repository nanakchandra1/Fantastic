//
//  GetStartedVC.swift
//  Fantasticoh!
//
//  Created by Shubham on 7/28/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout

class GetStartedVC: UIViewController {
    
    //MARK:- @IBOutlet and Propertie's
    //MARK:-
    @IBOutlet weak var getStaredCollectionView: UICollectionView!
    @IBOutlet weak var getStartedBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var pageNoController: UIPageControl!
    
    //let imageArray = ["walkthrough_1", "walkthrough_2", "card1"]
    let imageArray = ["1", "2", "3", "4", "5"]
    var visibleCellIndex: [IndexPath]!
    var onceOnly = true
    let layout = UPCarouselFlowLayout()
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        self.getStaredCollectionView.delegate = self
        self.getStaredCollectionView.dataSource = self
        self.getStaredCollectionView.layoutIfNeeded()
        self.view.layoutIfNeeded()
        
        self.getStaredCollectionView.collectionViewLayout.invalidateLayout()
        self.getStaredCollectionView.setCollectionViewLayout(layout, animated: false)
        if let layout = self.getStaredCollectionView.collectionViewLayout as? UPCarouselFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
//            layout.sideItemScale = 1.0//0.85
//            layout.sideItemAlpha = 0.55//0.6
//            layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 75)
            layout.itemSize = CGSize(width: self.getStaredCollectionView.bounds.size.width / 1.6, height: self.getStaredCollectionView.bounds.size.height)

            self.getStaredCollectionView.reloadData()
        }
        print_debug(object: self.descriptionLbl.font.fontName)
        self.initialSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getStaredCollectionView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    //MARK:- @IBAction, Selector & Private method's
    //MARK:-
    @IBAction func getStartedBtnTap(sender: UIButton) {
        
//        let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
//        self.navigationController?.pushViewController(tabBarVC, animated: true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
        vc.home3DTouchState = Home3DTouchState.Home
        let navi = UINavigationController(rootViewController: vc)
        navi.navigationBar.isHidden = true
        SHARED_APP_DELEGATE.window?.rootViewController = navi
    }

    private func initialSetup() {
        
        let indexPath = IndexPath(item: 151, section: 0)
        self.getStaredCollectionView.performBatchUpdates({
            
            self.getStaredCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
            
        }) { (update: Bool) in
            
        }
        
        self.descriptionLbl.text = CommonTexts.Walkthrough1
        self.pageNoController.isUserInteractionEnabled = false
        self.pageNoController.numberOfPages = 5
        self.getStartedBtn.layer.borderWidth = 1.5
        self.getStartedBtn.layer.borderColor = CommonColors.whiteColor().cgColor
        self.getStartedBtn.layer.cornerRadius = 5.0
        self.getStartedBtn.layer.masksToBounds = true
        
        self.getStaredCollectionView.showsVerticalScrollIndicator = false
        self.getStaredCollectionView.showsHorizontalScrollIndicator = false
        
        self.getStaredCollectionView.layoutIfNeeded()
    }
}

//MARK:- UICollectionView Delegate & DataSource
//MARK:-
extension GetStartedVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 300
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GetStaredCollectionViewCell", for:  indexPath) as! GetStaredCollectionViewCell
        
        let currentRow = indexPath.row % 5
        cell.imageView.image = UIImage(named: self.imageArray[currentRow])
        
        cell.imageView.layer.masksToBounds = true
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.getStaredCollectionView.bounds.size.width / 1.6, height: self.getStaredCollectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        //return VerticalDistance
        return 22.0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        var visibleRect: CGRect = CGRect()
        visibleRect.origin = self.getStaredCollectionView.contentOffset
        visibleRect.size = self.getStaredCollectionView.frame.size
        let visiblePoint: CGPoint = CGPoint(x: visibleRect.midX,y: visibleRect.midY)
        
        let visibleIndexPath: IndexPath = self.getStaredCollectionView.indexPathForItem(at: visiblePoint)!
        
        self.pageNoController.currentPage = visibleIndexPath.item % 5
        
        if self.pageNoController.currentPage == 0 {
            self.descriptionLbl.text = CommonTexts.Walkthrough1
            
        } else if self.pageNoController.currentPage == 1 {
            self.descriptionLbl.text = CommonTexts.Walkthrough2
            
        } else if self.pageNoController.currentPage == 2 {
            self.descriptionLbl.text = CommonTexts.Walkthrough3
        }else if self.pageNoController.currentPage == 3 {
            self.descriptionLbl.text = CommonTexts.Walkthrough4
        }else if self.pageNoController.currentPage == 4 {
            self.descriptionLbl.text = CommonTexts.Walkthrough5
        }
    }
}
