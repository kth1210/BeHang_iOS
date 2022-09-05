//
//  HomeViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit
import AVFoundation
import Alamofire
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let sectionInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    var isLoading = false
    var moreData = true
    var loadingView: LoadingCollectionView?
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let overlayView = UIView()
    let refreshControl = UIRefreshControl()
    let locationManager = CLLocationManager()
    
    var pageNo = 0
    
    var curX = 126.9784147
    var curY = 37.5666805
    
    lazy var list: [FeedInfo] = {
        var datalist = [FeedInfo]()
        return datalist
    }()
    
    //var selectFeed = FeedInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let loadingReusableNib = UINib(nibName: "LoadingCollectionView", bundle: nil)
        collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loadingCollectionView")
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        overlayView.frame = collectionView.bounds
        overlayView.center = collectionView.center
        overlayView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        
        self.view.addSubview(self.overlayView)
        self.view.addSubview(self.activityIndicator)
        
        overlayView.isHidden = false
        activityIndicator.startAnimating()
        
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
        case .denied:
            print("denied")
            self.locationManager.requestWhenInUseAuthorization()
            self.getFeed()
        case .restricted, .notDetermined:
            print("res, notDet")
            self.locationManager.requestWhenInUseAuthorization()
            self.getFeed()
        case .authorizedWhenInUse, .authorizedAlways:
            print("getCurrent")
            self.getCurrent()
        default:
            print("error")
        }
        
        
        //getCurrent()
//        getFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    
    @objc func refreshCollectionView() {
        print("refresh!!!")
        print("removeAll!!")
        self.list.removeAll()
        self.isLoading = true
        self.collectionView.reloadData()
        self.overlayView.isHidden = false
        self.moreData = true
        self.pageNo = 0
        
        getFeed()
        
    }
    
    @IBAction func uploadButtonPressed(_ sender: UIButton) {
        let nowLogin = UserDefaults.standard.string(forKey: "login")
        
        if nowLogin != "none" {
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadViewController") as? UploadViewController else {return}
            self.navigationController?.pushViewController(nextVC, animated: true)
        } else {
            let alert = UIAlertController(title: "알림", message: "로그인이 필요한 서비스입니다.", preferredStyle: UIAlertController.Style.alert)
            let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: nil)
        
            alert.addAction(confirm)
            self.present(alert, animated: true)
        }
        
    }

    func getFeed() {
        self.isLoading = true
        
        print("start Get Feed")
        let url = "http://35.247.33.79/posts/feed/sort=Distance?page=\(pageNo)&size=10"

        let bodyData : Parameters = [
            "curX" : curX,
            "curY" : curY
        ]
        
        AF.request(url,
                   //method: .get,
                   method: .post,
                   parameters: bodyData,
                   //encoding: URLEncoding.queryString,
                   encoding: JSONEncoding.default,
                   headers: nil//header
        )
        //.validate(statusCode: 200..<300)
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    print(asJSON)
                    let code = asJSON["code"] as! Int
                    
                    // 자체 토큰이 만료
                    if code == -1014 {
                        // 토큰 재발급
                        self.reissue()
                        return
                    }
                    
                    let list = asJSON["list"] as! NSArray
                    
                    // 다음 페이지 더 받아올 데이터가 없음
                    if list.count != 10 {
                        self.moreData = false
                    }
                    
                    for row in list {
                        let res = row as! NSDictionary
                        
                        let feedData = FeedInfo()
                        feedData.id = res["id"] as? Int
                        feedData.imageString = res["imageUrl"] as? String
                        feedData.contentId = res["contentId"] as? Int
                        
                        self.list.append(feedData)
                    }
                    self.collectionView.reloadData()
                    self.pageNo += 1
                    self.isLoading = false

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        print("merr")
                        self.overlayView.isHidden = true
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                    
                    print("Get Feed")
                } catch {
                    print("error")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getMoreFeed() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getFeed()
            self.isLoading = false
        }
    }
    
    func getCurrent() {
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        
        let coor = locationManager.location?.coordinate
        let latitude = coor?.latitude
        let longitude = coor?.longitude
        
        locationManager.stopUpdatingLocation()
        
        self.curX = longitude ?? 126.9784147
        self.curY = latitude ?? 37.5666805
        print("X: \(curX), Y: \(curY)")
        
        getFeed()
    }
    
    
    
    
    
    func reissue() {
        let loginUrl = "http://35.247.33.79/reissue"

        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
        
        let header : HTTPHeaders = [
            "Content-Type" : "application/json",
        ]

        let bodyData : Parameters = [
            "accessToken" : accessToken!,
            "refreshToken" : refreshToken!
        ] as Dictionary
        
        AF.request(
            loginUrl,
            method: .post,
            parameters: bodyData,
            encoding: JSONEncoding.default,
            headers: header
        )
        //.validate(statusCode: 200..<300)
        .responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary

                    let res = asJSON["data"] as! NSDictionary

                    // 자체 토큰 재발급
                    let xToken = res["accessToken"] as! String
                    let refreshToken = res["refreshToken"] as! String

                    UserDefaults.standard.setValue(xToken, forKey: "accessToken")
                    UserDefaults.standard.setValue(refreshToken, forKey: "refreshToken")

                    print(asJSON)
                    
                    self.getFeed()

                } catch {
                    print("error")
                }
            case .failure(let error):
                print("Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
    
    
    func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                 kCGImageSourceShouldCacheImmediately: true,
                                 kCGImageSourceCreateThumbnailWithTransform: true,
                                 kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }

}



extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
//        print("coll start")
//        print("indexPath = \(indexPath.row)")
//        && !self.collectionView.refreshControl!.isRefreshing₩
        if list.count != 0 {
            //print("refresh? : \(self.collectionView.refreshControl?.isRefreshing)")
            cell.id = list[indexPath.row].id
            //cell.imageView.image = list[indexPath.row].image
            
            if list[indexPath.row].image == nil {
                cell.imageView.image = UIImage(named: "loading")
                DispatchQueue.global(qos: .userInteractive).async {
//                    print("dispatch global")
                    
                    let url: URL! = Foundation.URL(string: "http://35.247.33.79/\(self.list[indexPath.row].imageString!)")
                    do {
                        //print(self.list)
                        print("indexPath = \(indexPath.row)")
//                        let imageData = try Data(contentsOf: url)
//                        self.list[indexPath.row].image = UIImage(data: imageData)
                        print(url)
                        self.list[indexPath.row].image = self.downsample(imageAt: url, to: CGSize(width: 400, height: 400), scale: 1.0)
                        print("end photo setting")
                    } catch {
                        self.list[indexPath.row].image = UIImage(systemName: "exclamationmark.triangle.fill")
                        print("feed load error")
                    }
    //                let imageData = try Data(contentsOf: url)
    //                self.list[indexPath.row].image = UIImage(data: imageData)
                    
                    DispatchQueue.main.async {
                        cell.imageView.image = self.list[indexPath.row].image
                    }
                    
//                    print("dispatch global end")
                }
            } else {
                cell.imageView.image = list[indexPath.row].image
            }
        }
        
        

        
//        cell.layer.masksToBounds = false
//        cell.layer.shadowOffset = .zero
//        cell.layer.shadowRadius = 3
//        cell.layer.shadowOpacity = 0.8
//        cell.layer.shadowColor = UIColor.black.cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageInfo = list[indexPath.row].image
        let postId = list[indexPath.row].id
        let contentId = list[indexPath.row].contentId

        // 선택한 포스트 불러오기
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController else {return}
        
        // 다음 뷰에 선택한 이미지랑 postId 전달
        nextVC.image = imageInfo
        nextVC.postId = postId
        nextVC.contentId = contentId
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.isLoading || !moreData{
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: 55)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "loadingCollectionView", for: indexPath) as! LoadingCollectionView
            loadingView = aFooterView
            loadingView?.backgroundColor = UIColor.clear
            return aFooterView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            print("willdisplay")
            self.loadingView?.activityIndicator.startAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            print("didenddisplay")
            self.loadingView?.activityIndicator.stopAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastSectionIndex = collectionView.numberOfSections - 1
        let lastRowIndex = collectionView.numberOfItems(inSection: lastSectionIndex) - 1
        
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex && moreData {
            getMoreFeed()
        }
        
    }
}


extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
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


extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image {
            context in self.draw(in: CGRect(origin: .zero, size: size))
        }
        print("화면 배율: \(UIScreen.main.scale)")// 배수
        print("origin: \(self), resize: \(renderImage)")
        return renderImage
        
    }
    
}
