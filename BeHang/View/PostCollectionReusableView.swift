//
//  PostCollectionReusableView.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/11.
//

import UIKit

class PostCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet var postView: UIView!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var placeName: UILabel!
    @IBOutlet var buttomPhoto: UILabel!
    
    @IBOutlet var tag1: UILabel!
    @IBOutlet var tag2: UILabel!
    @IBOutlet var tag3: UILabel!
    @IBOutlet var tag4: UILabel!
    @IBOutlet var tag5: UILabel!
    @IBOutlet var tag6: UILabel!
    
    var shareImage: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
            
        tag1.layer.cornerRadius = 10
        tag2.layer.cornerRadius = 10
        tag3.layer.cornerRadius = 10
        tag4.layer.cornerRadius = 10
        tag5.layer.cornerRadius = 10
        tag6.layer.cornerRadius = 10
        
        tag1.clipsToBounds = true
        tag2.clipsToBounds = true
        tag3.clipsToBounds = true
        tag4.clipsToBounds = true
        tag5.clipsToBounds = true
        tag6.clipsToBounds = true
    }
    
    func getShareImage() {
        guard let image = self.postView.convertToImage() else {return}
        shareImage = image
    }
    
    
    
}
