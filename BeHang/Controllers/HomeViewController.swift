//
//  HomeViewController.swift
//  BeHang
//
//  Created by κΉνν on 2022/07/29.
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
    
    let group = DispatchGroup()
    
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
        NetworkCheck.shared.stopMonitoring()

        let loadingReusableNib = UINib(nibName: "LoadingCollectionView", bundle: nil)
        collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loadingCollectionView")
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        overlayView.frame = collectionView.bounds
        overlayView.center = collectionView.center
        
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
            let alert = UIAlertController(title: "μλ¦Ό", message: "λ‘κ·ΈμΈμ΄ νμν μλΉμ€μλλ€.", preferredStyle: UIAlertController.Style.alert)
            let confirm = UIAlertAction(title: "νμΈ", style: UIAlertAction.Style.cancel, handler: nil)
        
            alert.addAction(confirm)
            self.present(alert, animated: true)
        }
        
    }

    func getFeed() {
        self.isLoading = true
        
        print("start Get Feed")
        let url = "http://\(urlConstants.release)/posts/feed/sort=Distance?page=\(pageNo)&size=10"

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
                    let code = asJSON["code"] as! Int

                    
                    let list = asJSON["list"] as! NSArray
                    
                    // λ€μ νμ΄μ§ λ λ°μμ¬ λ°μ΄ν°κ° μμ
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
                        self.group.notify(queue: .main) {
                            print("μ¬μ§ μ€μ  λ")
                            self.overlayView.isHidden = true
                            self.activityIndicator.stopAnimating()
                            self.refreshControl.endRefreshing()
                        }
                        
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
        
        getFeed()
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

        if list.count != 0 {
            cell.id = list[indexPath.row].id
            
            if list[indexPath.row].image == nil {
                cell.imageView.image = UIImage(named: "loading")
                DispatchQueue.global(qos: .userInteractive).async(group: group) {
                    
                    let url: URL! = Foundation.URL(string: "http://\(urlConstants.release)/\(self.list[indexPath.row].imageString!)")
                    do {
                        self.list[indexPath.row].image = self.downsample(imageAt: url, to: CGSize(width: 400, height: 400), scale: 1.0)
                    } catch {
                        self.list[indexPath.row].image = UIImage(systemName: "exclamationmark.triangle.fill")
                    }
                    
                    DispatchQueue.main.async {
                        cell.imageView.image = self.list[indexPath.row].image
                    }
                    
                }
            } else {
                cell.imageView.image = list[indexPath.row].image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageInfo = list[indexPath.row].image
        let postId = list[indexPath.row].id
        let contentId = list[indexPath.row].contentId

        // μ νν ν¬μ€νΈ λΆλ¬μ€κΈ°
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController else {return}
        
        // λ€μ λ·°μ μ νν μ΄λ―Έμ§λ postId μ λ¬
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

        return renderImage
        
    }
    
}
