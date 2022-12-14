//
//  ImageInfo.swift
//  BeHang
//
//  Created by κΉνν on 2022/08/08.
//

import UIKit

struct ImageInfo {
    let name: String
    
    var image: UIImage? {
        return UIImage(named: "\(name).png")
    }
    
    init (name: String) {
        self.name = name
    }
}
