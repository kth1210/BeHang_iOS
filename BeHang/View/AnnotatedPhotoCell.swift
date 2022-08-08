//
//  AnnotatedPhotoCell.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/03.
//

import UIKit

class AnnotatedPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
    }
    
    var photo: Photo? {
        didSet {
            if let photo = photo {
                imageView.image = photo.image
                //        captionLabel.text = photo.caption
                //        commentLabel.text = photo.comment
            }
        }
    }
}
