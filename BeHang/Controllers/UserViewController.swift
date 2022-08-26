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
    
    let activityIndicator = UIActivityIndicatorView(style: .large)

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let loadingReusableNib = UINib(nibName: "LoadingCollectionView", bundle: nil)
        collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loadingCollectionView")
        
        // Do any additional setup after loading the view.
        userLabel.layer.addBorder([.bottom], color: UIColor(hex: "AEAEAE"), width: 1.0)
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
        
//        if UserDefaults.standard.bool(forKey: "isLogin") {
//            self.setUserInfo()
//        } else {
//            self.userName.text = "로그인이 필요합니다."
//        }
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = .white
        //activityIndicator.backgroundColor = UIColor(named: "unselectedColor")
        activityIndicator.layer.cornerRadius = 10
        activityIndicator.hidesWhenStopped = true
        
        //self.view.addSubview(self.overlayView)
        self.view.addSubview(self.activityIndicator)
        
        //overlayView.isHidden = false
        activityIndicator.startAnimating()
        
        self.setUserInfo()
        self.getUserFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    

    
    
    
    
    
    func getUserFeed() {
        let nowLogin = UserDefaults.standard.string(forKey: "login")
        
        if nowLogin == "none" {
            return
        }
        
        self.isLoading = true
        
        print("start Get Feed")
        let url = "http://35.247.33.79:8080/posts/feed/me"
        let xToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : xToken
        ]
        
        var param : Parameters = [:]
        param["page"] = pageNo
        param["size"] = 10
        
        self.pageNo += 1
        
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
                    let list = asJSON["list"] as! NSArray
                    let msg = asJSON["msg"] as! String
                    let suc = asJSON["success"] as! Bool
                    
                    if list.count != 10 {
                        self.moreData = false
                    }
                    
                    for row in list {
                        let res = row as! NSDictionary
                        
                        let feedData = FeedInfo()
                        feedData.id = res["id"] as? Int
                        feedData.imageString = res["image"] as? String
                        
                        if let data = Data(base64Encoded: feedData.imageString!, options: .ignoreUnknownCharacters) {
                            let decodedImg = UIImage(data: data)
                            feedData.image = decodedImg
                        }
                        
                        self.list.append(feedData)
                    }
                    self.collectionView.reloadData()
                    self.isLoading = false
                    //self.overlayView.isHidden = true
                    self.activityIndicator.stopAnimating()
                    
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
//        UserApi.shared.me { user, error in
//            if let error = error {
//                print(error)
//            } else {
//                print("me() success")
//
//                _ = user
//                self.userName.text = user?.kakaoAccount?.profile?.nickname
//                if let url = user?.kakaoAccount?.profile?.profileImageUrl, let data = try? Data(contentsOf: url) {
//                    self.profileImage.image = UIImage(data: data)
//                }
//
//            }
//        }
        let nowLogin = UserDefaults.standard.string(forKey: "login")
        
        if nowLogin == "kakao" {
            
        } else if nowLogin == "apple" {
            self.userName.text = UserDefaults.standard.string(forKey: "appleName")
        } else {
            self.userName.text = "로그인이 필요합니다."
        }
        
        
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
        
        cell.id = list[indexPath.row].id
        cell.imageView.image = list[indexPath.row].image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageInfo = list[indexPath.row].image
        let postId = list[indexPath.row].id
        
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
            getMoreUserFeed()
        }
        
    }
}

extension UserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = 1
        
        let width: CGFloat = (collectionView.bounds.width - margin * 4) / 3
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}
