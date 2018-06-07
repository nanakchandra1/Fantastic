//
//  CelebHeaderViewXIB.swift
//  Fantasticoh!
//
//  Created by MAC on 6/1/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

protocol TagDelegate {
    func didTapOnTag(title: String)
}

// nitin
class CelebHeaderViewXIB: UIView {

    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var detailContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    //@IBOutlet weak var blurMiddleView: FXBlurView!
    @IBOutlet weak var blurMiddleView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var fanBtn: UIButton!
   
    @IBOutlet weak var chatBtn: UIButton!
    
    @IBOutlet weak var countBtn: UIButton!
   
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightcCons: NSLayoutConstraint!
    
    @IBOutlet weak var tagsIndicatorView: UIActivityIndicatorView!
    
    
    var displayLabel = [String]()
    var delegate: TagDelegate?
    
    //MARK:- Class Function
    //MARK:-
    class func instanciateFromNib() -> CelebHeaderViewXIB {
        return UINib(nibName: "CelebHeaderViewXIB", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CelebHeaderViewXIB
        //return Bundle.maim.loadNibNamed("CelebHeaderViewXIB", owner: self, options: nil)![0] as! CelebHeaderViewXIB
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tagsIndicatorView.color = UIColor.red
        self.tagsIndicatorView.startAnimating()
        self.initialSetups()
    }
}

extension CelebHeaderViewXIB {
    
    func initialSetups(){
        
        self.collectionView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
        
        self.collectionView.dataSource = self
        self.collectionView.delegate   = self
    }
}

extension CelebHeaderViewXIB : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.displayLabel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell else {
            fatalError("TagCollectionViewCell not fount")
        }
        
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: self.displayLabel[indexPath.item].uppercased(), attributes: underlineAttribute)
        cell.titleLabel.attributedText = underlineAttributedString
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
    
       
        let frame  = CommonFunctions.getTextHeightWdith(param: self.displayLabel[indexPath.item], font : CommonFonts.SFUIText_Regular(setsize: 13))
        
        return CGSize(width: frame.width + 20, height: 20)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.didTapOnTag(title: self.displayLabel[indexPath.item])
    }
}
