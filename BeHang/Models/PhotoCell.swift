//
//  PhotoCell.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/08.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var id: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 12
    }
    
    func update(info: ImageInfo) {
        imageView.image = info.image
    }
}
