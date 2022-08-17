//
//  ListCell.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/17.
//

import UIKit

class ListCell: UITableViewCell {
    @IBOutlet weak var placeImg: UIImageView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
