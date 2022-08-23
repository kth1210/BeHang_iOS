//
//  HomeViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit
import AVFoundation
import Alamofire

class HomeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var testImg: UIImageView!
    
    let viewModel = ImageViewModel()
    let sectionInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    var isLoading = false
    var loadingView: LoadingCollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let loadingReusableNib = UINib(nibName: "LoadingCollectionView", bundle: nil)
        collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loadingCollectionView")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    @IBAction func test(_ sender: UIButton) {
        //getPost()
        //users()
        getFeed()
    }
    
    func getFeed() {
        print("start Get Feed")
        let url = "http://35.247.33.79:8080/feed"
        let access = UserDefaults.standard.string(forKey: "accessToken")!
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : access
        ]
        
        var param : Parameters = [
            "page" : 0,
            "size" : 10
        ]
        
        AF.request(url,
                   method: .get,
                   parameters: param,
                   encoding: URLEncoding.queryString,
                   headers: header
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            
                    print("Get Feed")
                    print(asJSON)
                } catch {
                    print("error")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getPost() {
        let url = "http://35.247.33.79:8080/post/1"
        let access = UserDefaults.standard.string(forKey: "accessToken")!
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : access
        ]
        
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: JSONEncoding.default,
                   headers: header
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let res = asJSON["data"] as! NSDictionary
                    let img = res["imageFile"] as! String
                    
                    if let data = Data(base64Encoded: img, options: .ignoreUnknownCharacters) {
                        let decodedImg = UIImage(data: data)
                        
                        self.testImg.image = decodedImg
                    }
                    
                    
                    print("Get Post")
                    print(asJSON)
                } catch {
                    print("error")
                }
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    func users() {
        let url = "http://35.247.33.79:8080/v1/users"
        let access = UserDefaults.standard.string(forKey: "accessToken")!
        
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: JSONEncoding.default,
                   //encoding: URLEncoding.queryString,
                   //headers: ["Content-Type":"application/json", "Accept":"application/json"])
                   headers: ["X-AUTH-TOKEN" : access])
        .validate(statusCode: 200..<300)
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    
                    
                    print("userList result")
                    print(asJSON)
                } catch {
                    print("error")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}



extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.countOfImageList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.isLoading {
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

    public var base64: String {
        return self.jpegData(compressionQuality: 1.0)!.base64EncodedString()
    }

    convenience init?(base64: String, withPrefix: Bool) {
        var finalData: Data?

        if withPrefix {
            guard let url = URL(string: base64) else { return nil }
            finalData = try? Data(contentsOf: url)
        } else {
            finalData = Data(base64Encoded: base64)
        }

        guard let data = finalData else { return nil }
        self.init(data: data)
    }

}
