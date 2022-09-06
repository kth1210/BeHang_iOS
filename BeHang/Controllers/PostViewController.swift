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
    
    lazy var reportButton: UIBarButtonItem = {
        var image = UIImage(systemName: "exclamationmark.bubble")
        let button = UIBarButtonItem (image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(reportButtonPressed))
        return button
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        var image = UIImage(systemName: "trash")
        let button = UIBarButtonItem (image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(deleteButtonPressed))
        return button
    }()
    
    let sectionInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var tag1 = true
    var tag2 = true
    var tag3 = true
    var tag4 = true
    var tag5 = true
    var tag6 = true
    
    var isShareImage = true
    var isMine = false // 내 게시물에서 접근한 것인지
    var isMap = false
    
    var postId: Int?
    var image: UIImage?
    var shareImage: UIImage?
    var placeName: String?
    var contentId: Int?
    let overlayView = UIView()
    
    var loadingView: LoadingCollectionView?
    var isLoading = false
    var moreData = true
    var pageNo = 0
    var reissueCase = 0
    
    lazy var list: [FeedInfo] = {
        var datalist = [FeedInfo]()
        return datalist
    }()
    
    //var selectFeed = FeedInfo()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .black
        
        if isMine {
            // 내 피드에서 왔으면 삭제버튼
            self.navigationItem.rightBarButtonItem = self.deleteButton
        } else {
            // 다른 사람 포스트면 신고버튼
            print("다른사람포스트 신고버튼")
            self.navigationItem.rightBarButtonItem = self.reportButton
        }
        self.navigationItem.rightBarButtonItem?.tintColor = .black
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        let loadingReusableNib = UINib(nibName: "LoadingCollectionView", bundle: nil)
        collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loadingCollectionView")
        
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        overlayView.frame = collectionView.bounds
        overlayView.center = collectionView.center
        overlayView.layer.cornerRadius = 10
    
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.color = .white
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        
        self.view.addSubview(self.overlayView)
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubviewToFront(self.activityIndicator)
        
        overlayView.isHidden = false
        activityIndicator.startAnimating()
        
        // 메인 포스트 정보 가져오고
        if self.isMap{
            self.navigationItem.title = placeName
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.isShareImage = false
        } else {
            getPostInfo()
        }
   
        if self.isMine {
            // 내 피드에서 왔으면 내 피드 더 가져오기
            getMyFeed()
        } else {
            // 다른 사람 포스트면 같은 장소 사진 피드들 가져오기
            getSamePlaceFeed()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func getPostInfo() {
        print("start Get Post Info")
        self.reissueCase = 0
        
        if self.postId == nil {
            self.navigationItem.title = self.placeName
            self.isShareImage = false
        }
        
        let url = "http://35.247.33.79/posts/\(postId!)"
        
        var param : Parameters = [:]
        param["postId"] = postId
        
        
        AF.request(url,
                   method: .get,
                   parameters: param,
                   encoding: URLEncoding.queryString,
                   //encoding: JSONEncoding.default,
                   headers: nil
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
                    
                    if code == -1014 {
                        self.reissue()
                        return
                    } else if code == -1009 {
                        let alert = UIAlertController(title: "알림", message: "삭제된 포스트입니다.", preferredStyle: UIAlertController.Style.alert)
                        let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel) { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                        alert.addAction(confirm)
                        self.present(alert, animated: true)
                        return
                    }
                    
                    let data = asJSON["data"] as! NSDictionary
                    
                    let place = data["place"] as! NSDictionary
                    self.placeName = place["name"] as? String
                    self.contentId = place["contentId"] as? Int
                    
                    self.navigationItem.title = place["name"] as? String
                    
                    let tag = data["tag"] as! NSDictionary
                    self.tag1 = tag["convenientParking"] as! Bool
                    self.tag2 = tag["comfortablePubTransit"] as! Bool
                    self.tag3 = tag["withChild"] as! Bool
                    self.tag4 = tag["indoor"] as! Bool
                    self.tag5 = tag["withLover"] as! Bool
                    self.tag6 = tag["withMyDog"] as! Bool
                    
                    print("Get Feed")
                    
                    self.isShareImage = false
                    self.collectionView.reloadData()
                    
                } catch {
                    print("error")
                }
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    func getSamePlaceFeed() {
        self.reissueCase = 1
        
        self.isLoading = true
        
        print("start Get Feed")
        let url = "http://35.247.33.79/posts/feed/place/\(contentId ?? 0)"
        print(url)
        
        var param : Parameters = [:]
        param["contentId"] = self.contentId
        
        AF.request(url,
                   method: .get,
                   parameters: param,
                   encoding: URLEncoding.queryString,
                   //encoding: JSONEncoding.default,
                   headers: nil
        )
        //.validate(statusCode: 200..<300)
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let code = asJSON["code"] as! Int
                    print(code)
                    // 자체 토큰이 만료
                    if code == -1014 {
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
                        feedData.contentId = res["contentId"] as? Int
//                        let imageUrl = "http://35.247.33.79/\(feedData.imageString!)"
//
//                        if feedData.imageString != "" {
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
    
    func getMyFeed() {
        self.reissueCase = 2
        
        let nowLogin = UserDefaults.standard.string(forKey: "login")
        
        if nowLogin == "none" {
            return
        }
        
        self.isLoading = true
        
        print("start Get Feed")
        let url = "http://35.247.33.79/posts/feed/me"
        let xToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : xToken
        ]
        
        var param : Parameters = [:]
        param["page"] = pageNo
        param["size"] = 10
        
        AF.request(url,
                   method: .get,
                   parameters: param,
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
                    if code == -1014 {
                        // 토큰 재발급
                        self.reissue()
                        return
                    }
                    
                    let list = asJSON["list"] as! NSArray
                    //let msg = asJSON["msg"] as! String
                    //let suc = asJSON["success"] as! Bool
                    
                    if list.count != 10 {
                        self.moreData = false
                    }
                    
                    for row in list {
                        let res = row as! NSDictionary
                        
                        let feedData = FeedInfo()
                        feedData.id = res["id"] as? Int
                        feedData.imageString = res["imageUrl"] as? String
//                        let imageUrl = "http://35.247.33.79/\(feedData.imageString!)"
//
//                        if feedData.imageString != "" {
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
    

    @objc func shareButtonPressed() {
        
        print("shareButtonPressed()")
        if let shareImage = shareImage {
            
            let activityViewController = UIActivityViewController(activityItems: [shareImage], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .openInIBooks, .postToFlickr, .postToWeibo, .postToVimeo, .postToTencentWeibo]
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func deleteButtonPressed() {
        self.reissueCase = 3
        
        let alert = UIAlertController(title: "알림", message: "게시물을 삭제하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        let confirm = UIAlertAction(title: "삭제", style: UIAlertAction.Style.destructive) { _ in
            self.overlayView.isHidden = false
            self.activityIndicator.startAnimating()
            
            let url = "http://35.247.33.79/posts/\(self.postId!)"
            let xToken = UserDefaults.standard.string(forKey: "accessToken")!
            
            let header : HTTPHeaders = [
                "X-AUTH-TOKEN" : xToken
            ]
            
            var param : Parameters = [:]
            param["postId"] = self.postId
            
            
            AF.request(url,
                       method: .delete,
                       parameters: param,
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
                        
                        if code == -1014 {
                            self.reissue()
                            return
                        }
                        
                        print("delete Success")
                        
                        self.navigationController?.popViewController(animated: true)
                        
                    } catch {
                        print("error")
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    @objc func reportButtonPressed() {
        self.reissueCase = 4
        
        let alert = UIAlertController(title: "부적절한 게시물", message: "게시물을 신고하시겠습니까?/n(검토 이후 게시물이 삭제되거나 제재가 있을 수 있습니다.)", preferredStyle: UIAlertController.Style.alert)
        let confirm = UIAlertAction(title: "신고", style: UIAlertAction.Style.destructive) { _ in
            self.overlayView.isHidden = false
            self.activityIndicator.startAnimating()
            
            let url = "http://35.247.33.79/report/\(self.postId!)"
            let xToken = UserDefaults.standard.string(forKey: "accessToken")!
            
            let header : HTTPHeaders = [
                "X-AUTH-TOKEN" : xToken
            ]
            
            var param : Parameters = [:]
            param["postId"] = self.postId
            
            
            AF.request(url,
                       method: .post,
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
                        let code = asJSON["code"] as! Int
                        
                        if code == -1014 {
                            self.reissue()
                            return
                        }
                        
                        print("report Success")
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        self.navigationController?.popViewController(animated: true)
                        
                    } catch {
                        print("error")
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        
        
        let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    func getMoreFeed() {
        if isMine {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.getMyFeed()
                self.isLoading = false
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.getSamePlaceFeed()
                self.isLoading = false
            }
        }
    }
    
    // 토큰 만료 처리
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
                    
                    print("토큰 재발급")
                    print(asJSON)

                    switch self.reissueCase {
                    case 0:
                        self.getPostInfo()
                    case 1:
                        self.getSamePlaceFeed()
                    case 2:
                        self.getMyFeed()
                    case 3:
                        self.deleteButtonPressed()
                    case 4:
                        self.reportButtonPressed()
                    default:
                        print("error")
                    }
                    
                } catch {
                    print("error")
                }
            case .failure(let error):
                print("Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }

}


//MARK: - CollectionView Setting

extension PostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list.count
    }
    
    // 셀 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postPhotoCell", for: indexPath) as? PhotoCell else {
            print("error")
            return UICollectionViewCell()
        }
        
        cell.id = list[indexPath.row].id
//        cell.imageView.image = list[indexPath.row].image
        
        if list[indexPath.row].image == nil {
            DispatchQueue.global(qos: .userInteractive).async {
                print("dispatch global")
                
                let url: URL! = Foundation.URL(string: "http://35.247.33.79/\(self.list[indexPath.row].imageString!)")
                let imageData = try! Data(contentsOf: url)
                self.list[indexPath.row].image = UIImage(data: imageData)
                
                DispatchQueue.main.async {
                    cell.imageView.image = self.list[indexPath.row].image
                }
                
                print("dispatch global end")
            }
        } else {
            cell.imageView.image = list[indexPath.row].image
        }
        
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = .zero
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.8
        cell.layer.shadowColor = UIColor.black.cgColor

        return cell
    }
    
    // 사진 선택했을때 다음 포스트 설정
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
        nextVC.isMine = self.isMine
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // collecvionView 헤더 설정
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PostCollectionReusableView", for: indexPath)
            
            guard let typedHeaderView = headerView as? PostCollectionReusableView else { return headerView }
            typedHeaderView.imgView.image = self.image
            typedHeaderView.placeName.text = self.placeName
            
            if self.isMine {
                typedHeaderView.bottomLabel.text = "내가 올린 사진"
            } else {
                typedHeaderView.bottomLabel.text = "같은 장소의 사진"
            }
            
            if self.isMap {
                typedHeaderView.tag1.isHidden = true
                typedHeaderView.tag2.isHidden = true
                typedHeaderView.tag3.isHidden = true
                typedHeaderView.tag4.isHidden = true
                typedHeaderView.tag5.isHidden = true
                typedHeaderView.tag6.isHidden = true
            }
            
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
        case UICollectionView.elementKindSectionFooter:
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "loadingCollectionView", for: indexPath) as! LoadingCollectionView
            loadingView = aFooterView
            loadingView?.backgroundColor = UIColor.clear
            return aFooterView
        default:
            assert(false, "error")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.isLoading || !moreData{
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: 55)
        }
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
            getMoreFeed()
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
