//
//  PostViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/19.
//

import UIKit

class PostViewController: UIViewController {

    var image: UIImage?
    var shareImage: UIImage?
    var placeName: String?
    let viewModel = ImageViewModel()
    let sectionInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = placeName
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func shareButtonPressed() {
        print("shareButtonPressed()")
        if let shareImage = shareImage {
            
            let activityViewController = UIActivityViewController(activityItems: [shareImage], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .openInIBooks, .postToFlickr, .postToWeibo, .postToVimeo, .postToTencentWeibo]
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
//
    
    

}

extension PostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.countOfImageList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postPhotoCell", for: indexPath) as? PostPhotoCell else {
            print("error")
            return UICollectionViewCell()
        }
        
        cell.layer.cornerRadius = 10
        
        let imageInfo = viewModel.imageInfo(at: indexPath.item)
        cell.update(info: imageInfo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageInfo = viewModel.imageInfo(at: indexPath.item)
        
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController else {return}
        nextVC.image = imageInfo.image
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PostCollectionReusableView", for: indexPath)
            
//            var img: UIImageView!
//            img = UIImageView(frame: CGRect(x: 0, y: 0, width: 390, height: 390))
//
//            img.image = image
//            //img.layer.position = CGPoint(x: 0, y: 0)
//            headerView.addSubview(img)
//
            guard let typedHeaderView = headerView as? PostCollectionReusableView else { return headerView }
            typedHeaderView.imgView.image = image
            print("여기임 ㅋㅋ")
            typedHeaderView.getShareImage()
            self.shareImage = typedHeaderView.shareImage
            
            typedHeaderView.shareButton.tag = indexPath.row
            typedHeaderView.shareButton.addTarget(self, action: #selector(self.shareButtonPressed), for: .touchUpInside)
            
            return typedHeaderView
        default:
            assert(false, "error")
        }
    }
}

extension PostViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let margin: CGFloat = 12
        
        let width: CGFloat = (collectionView.bounds.width - margin * 3) / 2
        let height: CGFloat = width
        
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}

extension UIView {
    func convertToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
}
