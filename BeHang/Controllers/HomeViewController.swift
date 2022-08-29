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
    
    var pageNo = 0
    
    var curX: Double?
    var curY: Double?
    
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
        
        getCurrent()
//        getFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func refreshCollectionView() {
        self.list.removeAll()
        self.overlayView.isHidden = false
        
        self.pageNo = 0
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.getFeed()
//        }
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
    
    @IBAction func test(_ sender: UIButton) {
        
        getFeed()
    }
    
    func getFeed() {
        self.isLoading = true
        
        print("start Get Feed")
//        let url = "http://35.247.33.79/posts/feed"
        let url = "http://35.247.33.79/posts/feed/sort=Distance?page=\(pageNo)&size=10"
        
//        let header : HTTPHeaders = [
//            "X-AUTH-TOKEN" : xToken
//        ]
        
        let bodyData : Parameters = [
            "curX" : curX!,
            "curY" : curY!
        ]
        
//        var param : Parameters = [:]
//        param["page"] = pageNo
//        param["size"] = 10
        
        //self.pageNo += 1
        
        AF.request(url,
                   //method: .get,
                   method: .post,
                   parameters: bodyData,
                   //encoding: URLEncoding.queryString,
                   encoding: JSONEncoding.default,
                   headers: nil//header
        )
        .validate(statusCode: 200..<300)
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
                    //let msg = asJSON["msg"] as! String
                    //let suc = asJSON["success"] as! Bool
                    
                    // 다음 페이지 더 받아올 데이터가 없음
                    if list.count != 10 {
                        self.moreData = false
                    }
                    
                    for row in list {
                        let res = row as! NSDictionary
                        
                        let feedData = FeedInfo()
                        feedData.id = res["id"] as? Int
                        feedData.imageString = res["imageUrl"] as? String
//                        let imageUrl = "http://35.247.33.79/\(feedData.imageString!)"

//                        if feedData.imageString != "" {
//                            DispatchQueue.global(qos: .userInteractive).async {
//                                let url: URL! = Foundation.URL(string: imageUrl)
//                                let imageData = try! Data(contentsOf: url)
//                                feedData.image = UIImage(data: imageData)
//                                self.list.append(feedData)
//                            }
//                            let url: URL! = Foundation.URL(string: imageUrl)
//                            let imageData = try! Data(contentsOf: url)
//                            feedData.image = UIImage(data: imageData)
                            
//                        }
                        
                        self.list.append(feedData)
                    }
                    self.collectionView.reloadData()
                    self.pageNo += 1
                    self.isLoading = false
//                    self.overlayView.isHidden = true
//                    self.activityIndicator.stopAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        
        let coor = locationManager.location?.coordinate
        let latitude = coor?.latitude
        let longitude = coor?.longitude
        
        locationManager.stopUpdatingLocation()
        
        self.curX = longitude
        self.curY = latitude
//        print("X: \(curX), Y: \(curY)")
        
        getFeed()
    }
    
    
    
    
    
    func reissue() {
        let loginUrl = "http://35.247.33.79/reissue"

        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
        
        let header : HTTPHeaders = [
            "Content-Type" : "application/json",
            //"X-AUTH-TOKEN" : accessToken!
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
        .validate(statusCode: 200..<300)
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
    
}



extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        print("coll start")
        print("indexPath = \(indexPath.row)")
        
        cell.id = list[indexPath.row].id
        //cell.imageView.image = list[indexPath.row].image
        
        if list[indexPath.row].image == nil {
            DispatchQueue.global(qos: .userInteractive).async {
                print("dispatch global")
                
                let url: URL! = Foundation.URL(string: "http://35.247.33.79/\(self.list[indexPath.row].imageString!)")
                do {
                    let imageData = try Data(contentsOf: url)
                    self.list[indexPath.row].image = UIImage(data: imageData)
                } catch {
                    self.list[indexPath.row].image = UIImage(systemName: "exclamationmark.triangle.fill")
                    print("feed load error")
                }
//                let imageData = try Data(contentsOf: url)
//                self.list[indexPath.row].image = UIImage(data: imageData)
                
                DispatchQueue.main.async {
                    cell.imageView.image = self.list[indexPath.row].image
                }
                
                print("dispatch global end")
            }
        } else {
            cell.imageView.image = list[indexPath.row].image
        }
        
//            let url: URL! = Foundation.URL(string: "http://35.247.33.79/\(self.list[indexPath.row].imageString!)")
//            let imageData = try! Data(contentsOf: url)
//            self.list[indexPath.row].image = UIImage(data: imageData)
//            cell.imageView.image = self.list[indexPath.row].image
//            print("dispatch end")

        
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = .zero
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.8
        cell.layer.shadowColor = UIColor.black.cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageInfo = list[indexPath.row].image
        let postId = list[indexPath.row].id
        
        // 선택한 포스트 불러오기
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController else {return}
        
        // 다음 뷰에 선택한 이미지랑 postId 전달
        nextVC.image = imageInfo
        nextVC.postId = postId
        
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
//            if self.isLoading {
//                self.loadingView?.activityIndicator.startAnimating()
//            } else {
//                self.loadingView?.activityIndicator.stopAnimating()
//            }
            self.loadingView?.activityIndicator.startAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.activityIndicator.stopAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if self.moreData == true && self.isLoading == false {
//            self.isLoading = true
//            getMoreFeed()
//        }
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
