//
//  PostViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/19.
//

import UIKit
import Alamofire

class PostViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    
    var tag1 = true
    var tag2 = true
    var tag3 = true
    var tag4 = true
    var tag5 = true
    var tag6 = true
    
    var postId: Int?
    var image: UIImage?
    var shareImage: UIImage?
    var placeName: String?
    let viewModel = ImageViewModel()
    let sectionInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var isShareImage = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = .black
        //self.navigationItem.title = placeName
        
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubviewToFront(self.activityIndicator)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.color = .white
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.startAnimating()
        
        getPostInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func getPostInfo() {
        print("start Get Post Info")
        let url = "http://35.247.33.79:8080/post/\(postId!)"
        let xToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : xToken
        ]
        
        var param : Parameters = [:]
        param["postId"] = postId
        
        
        AF.request(url,
                   method: .get,
                   parameters: param,
                   encoding: URLEncoding.queryString,
                   //encoding: JSONEncoding.default,
                   headers: header
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let data = asJSON["data"] as! NSDictionary
                    //let imageFile = data["imageFile"] as! String
                    
                    let place = data["place"] as! NSDictionary
                    self.placeName = place["name"] as? String
                    
                    self.navigationItem.title = place["name"] as? String
                    
                    let tag = data["tag"] as! NSDictionary
                    self.tag1 = tag["convenientParking"] as! Bool
                    self.tag2 = tag["comfortablePubTransit"] as! Bool
                    self.tag3 = tag["withChild"] as! Bool
                    self.tag4 = tag["indoor"] as! Bool
                    self.tag5 = tag["withLover"] as! Bool
                    self.tag6 = tag["withMyDog"] as! Bool
                    
                    
                    print("Get Feed")
                    //print(asJSON)
                    
                    self.isShareImage = false
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                } catch {
                    print("error")
                }
            case .failure(let error):
                print(error)
            }
        }
        
        
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
            
            guard let typedHeaderView = headerView as? PostCollectionReusableView else { return headerView }
            typedHeaderView.imgView.image = self.image
            typedHeaderView.placeName.text = self.placeName
            
            
            if self.tag1 == false{
                typedHeaderView.tag1.backgroundColor = UIColor(named: "unselectedColor")
            }
            if self.tag2 == false{
                typedHeaderView.tag2.backgroundColor = UIColor(named: "unselectedColor")
            }
            if self.tag3 == false{
                typedHeaderView.tag3.backgroundColor = UIColor(named: "unselectedColor")
            }
            if self.tag4 == false{
                typedHeaderView.tag4.backgroundColor = UIColor(named: "unselectedColor")
            }
            if self.tag5 == false{
                typedHeaderView.tag5.backgroundColor = UIColor(named: "unselectedColor")
            }
            if self.tag6 == false{
                typedHeaderView.tag6.backgroundColor = UIColor(named: "unselectedColor")
            }
            
            
            // 공유할 이미지 안가져왔을때만 부르기
            if isShareImage == false {
                print(typedHeaderView.placeName.text!)
                print("get Share")
                typedHeaderView.getShareImage()
                isShareImage = true
            }
            
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
