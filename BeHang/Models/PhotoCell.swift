//
//  PhotoCell.swift
//  BeHang
//
//  Created by κΉνν on 2022/08/08.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var id: Int?
    var contentId: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 12
    }

}
