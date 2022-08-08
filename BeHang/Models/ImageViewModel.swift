//
//  ImageViewModel.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/08.
//

import Foundation

class ImageViewModel {
    let imageInfoList: [ImageInfo] = [
        ImageInfo(name: "01"),
        ImageInfo(name: "02"),
        ImageInfo(name: "03"),
        ImageInfo(name: "04"),
        ImageInfo(name: "05"),
        ImageInfo(name: "06"),
        ImageInfo(name: "07"),
        ImageInfo(name: "08"),
    ]
    
    var countOfImageList: Int {
        return imageInfoList.count
    }
    
    func imageInfo(at index: Int) -> ImageInfo {
        return imageInfoList[index]
    }
}
