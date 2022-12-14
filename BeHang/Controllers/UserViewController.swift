//
//  UserViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit
import KakaoSDKUser
import Alamofire

class UserViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet var changeProfileButton: UIButton!
    
    let sectionInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    var isLoading = false
    var moreData = true
    var loadingView: LoadingCollectionView?
    var pageNo = 0
    lazy var list: [FeedInfo] = {
        var datalist = [FeedInfo]()
        return datalist
    }()
    var selectFeed = FeedInfo()
    let userFeedGroup = DispatchGroup()
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let refreshControl = UIRefreshControl()
    let overlayView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeProfileButton.layer.cornerRadius = 10
        if UserDefaults.standard.string(forKey: "login") == "none" {
            print("로그인으로 이동")
            changeProfileButton.setTitle("로그인으로 이동", for: .normal)
        }
        
        let loadingReusableNib = UINib(nibName: "LoadingCollectionView", bundle: nil)
        collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loadingCollectionView")
        collectionView.refreshControl = refreshControl
        // Do any additional setup after loading the view.
        userLabel.layer.addBorder([.bottom], color: UIColor(hex: "AEAEAE"), width: 1.0)
        
        refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
        
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        overlayView.frame = view.bounds
        overlayView.center = view.center
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        
        self.view.addSubview(self.activityIndicator)
        self.view.addSubview(self.overlayView)
        self.view.bringSubviewToFront(activityIndicator)
        
        overlayView.isHidden = false
        activityIndicator.startAnimating()
        
        self.setUserInfo()
        self.getUserFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    @objc func refreshCollectionView() {
        self.list.removeAll()
        self.overlayView.frame = self.collectionView.bounds
        self.overlayView.center = self.collectionView.center
        
        self.overlayView.isHidden = false
        
        self.pageNo = 0

        getUserFeed()
        
    }
    
    func getUserFeed() {
        let nowLogin = UserDefaults.standard.string(forKey: "login")
        
        if nowLogin == "none" {
            self.collectionView.isHidden = true
            self.overlayView.isHidden = true
            self.activityIndicator.stopAnimating()
            return
        }
        
        self.isLoading = true
        
        print("start Get Feed")
        let url = "http://\(urlConstants.release)/posts/feed/me"
        let xToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : xToken
        ]
        
        var param : Parameters = [:]
        param["page"] = pageNo
        param["size"] = 15
        
        AF.request(url,
                   method: .get,
                   parameters: param,
                   encoding: URLEncoding.queryString,
                   headers: header
        )
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let code = asJSON["code"] as! Int
                    
                    // 자체 토큰이 만료
                    if code == -1011 {
                        // 토큰 재발급
                        self.reissue()
                        return
                    }
                    
                    let list = asJSON["list"] as! NSArray
                    
                    if list.count != 10 {
                        self.moreData = false
                    }
                    
                    for row in list {
                        let res = row as! NSDictionary
                        
                        let feedData = FeedInfo()
                        feedData.id = res["id"] as? Int
                        feedData.imageString = res["imageUrl"] as? String
                        
                        self.list.append(feedData)
                    }
                    self.collectionView.reloadData()
                    self.pageNo += 1
                    self.isLoading = false

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.userFeedGroup.notify(queue: .main) {
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
    
    func getMoreUserFeed() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getUserFeed()
            self.isLoading = false
        }
    }
    
    
    func setUserInfo() {
        let nowLogin = UserDefaults.standard.string(forKey: "login")

        if nowLogin == "none" {
            self.userName.text = "게스트"
        } else {
            let url = "http://\(urlConstants.release)/users/profile/me"
            let xToken = UserDefaults.standard.string(forKey: "accessToken")!
            
            let header : HTTPHeaders = [
                "X-AUTH-TOKEN" : xToken
            ]

            AF.request(url,
                       method: .get,
                       parameters: nil,
                       encoding: URLEncoding.queryString,
                       //encoding: JSONEncoding.default,
                       headers: header
            )
            //.validate(statusCode: 200..<300)
            .responseData { response in
                print(response)
                switch response.result {
                case .success(let data):
                    do {
                        let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                        let code = asJSON["code"] as! Int
                        
                        // 자체 토큰이 만료
                        if code == -1011 {
                            // 토큰 재발급
                            print("call reissue")
                            self.reissue()
                            return
                        }
                        
                        let data = asJSON["data"] as! NSDictionary
                        let name = data["nickName"] as! String
                        let imagestr = data["profileImage"] as! String
                        
                        let imageURL: URL!
                        if imagestr.prefix(2) == "ht" {
                            imageURL = Foundation.URL(string: imagestr)
                        } else {
                            imageURL = Foundation.URL(string: "http://\(urlConstants.release)/\(imagestr)")
                        }
                        
                        
                        self.profileImage.image = self.downsample(imageAt: imageURL, to: CGSize(width: 200, height: 200), scale: 1.0)
                        self.userName.text = name
                        
                        print("Get Feed")
                    } catch {
                        print("error")
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    @IBAction func changeProfileButtonPressed(_ sender: UIButton) {
        if UserDefaults.standard.string(forKey: "login") == "none" {
            performSegue(withIdentifier: "unwindToLaunch", sender: self)
        }
        
        
        guard let nextVC = UIStoryboard(name: "ChangeProfileView", bundle: nil).instantiateViewController(withIdentifier: "ChangeProfileViewController") as? ChangeProfileViewController else {return}
        
        nextVC.image = self.profileImage.image
        nextVC.name = self.userName.text
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func reissue() {
        let loginUrl = "http://\(urlConstants.release)/reissue"

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
        .responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let code = asJSON["code"] as! Int
                    
                    // 자체 토큰이 만료
                    if code == -1014 {
                        // 토큰 재발급
                        let alert = UIAlertController(title: "알림", message: "로그인이 만료되었습니다. 다시 로그인해주세요.", preferredStyle: UIAlertController.Style.alert)
                        let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { _ in
                            UserDefaults.standard.setValue("none", forKey: "login")
                            UserDefaults.standard.setValue(false, forKey: "isLogin")
                            self.performSegue(withIdentifier: "unwindToLaunch", sender: self)
                        }
                    
                        alert.addAction(confirm)
                        self.present(alert, animated: true)
                        
                        return
                    }

                    let res = asJSON["data"] as! NSDictionary

                    // 자체 토큰 재발급
                    let xToken = res["accessToken"] as! String
                    let refreshToken = res["refreshToken"] as! String

                    UserDefaults.standard.setValue(xToken, forKey: "accessToken")
                    UserDefaults.standard.setValue(refreshToken, forKey: "refreshToken")
                    
                    print("토큰 재발급")
                    
                    self.getUserFeed()

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

extension UserViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myPhotoCell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        if !list.isEmpty {
            cell.id = list[indexPath.row].id
            cell.imageView.layer.cornerRadius = 8
            
            if list[indexPath.row].image == nil {
                cell.imageView.image = UIImage(named: "loading")
                DispatchQueue.global(qos: .userInteractive).async(group: userFeedGroup) {
                    
                    let url: URL! = Foundation.URL(string: "http://\(urlConstants.release)/\(self.list[indexPath.row].imageString!)")
                    let imageData = try! Data(contentsOf: url)
                    self.list[indexPath.row].image = UIImage(data: imageData)
                    
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
        
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController else {return}
        
        // 다음 뷰에 선택한 이미지랑 postId 전달
        nextVC.image = imageInfo
        nextVC.postId = postId
        nextVC.isMine = true
        
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
            print("start animating")
            self.loadingView?.activityIndicator.startAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            print("stop animating")
            self.loadingView?.activityIndicator.stopAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let lastSectionIndex = collectionView.numberOfSections - 1
        let lastRowIndex = collectionView.numberOfItems(inSection: lastSectionIndex) - 1
        
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex && moreData {
            getMoreUserFeed()
        }
        
    }
}

extension UserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = 2
        //let padding: CGFloat = margin * 4
        let width: CGFloat = (collectionView.bounds.width - margin * 2) / 3
        //let width: CGFloat = (collectionView.frame.width - padding) / 3 - 4
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
