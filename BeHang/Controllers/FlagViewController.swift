//
//  FlagViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit
import Alamofire

class FlagViewController: UIViewController {
    @IBOutlet var sharingView: UIView!
    @IBOutlet var shareInstagramButton: UIButton!
    
    @IBOutlet var seoulFlag: UIImageView!
    @IBOutlet var incheonFlag: UIImageView!
    @IBOutlet var daejeonFlag: UIImageView!
    @IBOutlet var daeguFlag: UIImageView!
    @IBOutlet var gwangjuFlag: UIImageView!
    @IBOutlet var busanFlag: UIImageView!
    @IBOutlet var ulsanFlag: UIImageView!
    @IBOutlet var sejongFlag: UIImageView!
    @IBOutlet var gyeonggiFlag: UIImageView!
    @IBOutlet var gangwonFlag: UIImageView!
    @IBOutlet var chungbukFlag: UIImageView!
    @IBOutlet var chungnamFlag: UIImageView!
    @IBOutlet var kyungbukFlag: UIImageView!
    @IBOutlet var kyungnamFlag: UIImageView!
    @IBOutlet var jeonbukFlag: UIImageView!
    @IBOutlet var jeonnamFlag: UIImageView!
    @IBOutlet var jejuFlag: UIImageView!
    
    var flagArr : [UIImageView]!
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        seoulFlag.isHidden = true
        incheonFlag.isHidden = true
        daejeonFlag.isHidden = true
        daeguFlag.isHidden = true
        gwangjuFlag.isHidden = true
        busanFlag.isHidden = true
        ulsanFlag.isHidden = true
        sejongFlag.isHidden = true
        gyeonggiFlag.isHidden = true
        gangwonFlag.isHidden = true
        chungbukFlag.isHidden = true
        chungnamFlag.isHidden = true
        kyungbukFlag.isHidden = true
        kyungnamFlag.isHidden = true
        jeonbukFlag.isHidden = true
        jeonnamFlag.isHidden = true
        jejuFlag.isHidden = true
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)

        if UserDefaults.standard.string(forKey: "login") != "none" {
            activityIndicator.startAnimating()
            getHistory()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey: "login") != "none" {
            activityIndicator.startAnimating()
            getHistory()
        }
    }
    
    @IBAction func shareInstagramButtonPressed(_ sender: UIButton) {
        
        if let storyShareURL = URL(string: "instagram-stories://share") {
            if UIApplication.shared.canOpenURL(storyShareURL) {
                let renderer = UIGraphicsImageRenderer(size: sharingView.bounds.size)
                
                let renderImage = renderer.image { _ in
                    sharingView.drawHierarchy(in: sharingView.bounds, afterScreenUpdates: true)
                }
                
                guard let imageData = renderImage.pngData() else {return}
                
                let pasteboardItems : [String:Any] = [
                    "com.instagram.sharedSticker.stickerImage" : imageData,
                    "com.instagram.sharedSticker.backgroundTopColor" : "#636e72",
                    "com.instagram.sharedSticker.backgroundBottomColor" : "#b2becc3"
                ]
                
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate : Date().addingTimeInterval(300)
                ]
                
                UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                
                UIApplication.shared.open(storyShareURL, options: [:], completionHandler: nil)
            } else {
                let alert = UIAlertController(title: "알림", message: "인스타그램이 설치되어 있지 않습니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getHistory() {
        let signupUrl = "http://\(urlConstants.release)/history"

        
        let xToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : xToken
        ]

        
        AF.request(
            signupUrl,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: header
        )
        .responseData { (response) in
            switch response.result {
            case .success(let data):
                // 회원가입 성공하면 애플 토큰, 이름으로 로그인
                do{
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let code = asJSON["code"] as! Int
                    if code == -1011 {
                        // 토큰 재발급
                        print("call reissue()")
                        self.reissue()
                        return
                    }
                    
                    let list = asJSON["list"] as! [[String:Any]]
                    
                    for data in list {
                        let areaName = data["areaName"] as! String
                        let count = data["numOfPlace"] as! Int
                        
                        switch areaName {
                        case "Seoul":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.seoulFlag.isHidden = false
                                }
                            }
                        case "Incheon":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.incheonFlag.isHidden = false
                                }
                            }
                        case "Daejeon":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.daejeonFlag.isHidden = false
                                }
                            }
                        case "Daegu":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.daeguFlag.isHidden = false
                                }
                            }
                        case "Gwangju":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.gwangjuFlag.isHidden = false
                                }
                            }
                        case "Busan":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.busanFlag.isHidden = false
                                }
                            }
                        case "Ulsan":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.ulsanFlag.isHidden = false
                                }
                            }
                        case "Sejong":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.sejongFlag.isHidden = false
                                }
                            }
                        case "Gyeonggi":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.gyeonggiFlag.isHidden = false
                                }
                            }
                        case "Gangwon":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.gangwonFlag.isHidden = false
                                }
                            }
                        case "Chungbuk":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.chungbukFlag.isHidden = false
                                }
                            }
                        case "Chungnam":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.chungnamFlag.isHidden = false
                                }
                            }
                        case "Gyungbuk":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.kyungbukFlag.isHidden = false
                                }
                            }
                        case "Gyungnam":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.kyungnamFlag.isHidden = false
                                }
                            }
                        case "Jeonbuk":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.jeonbukFlag.isHidden = false
                                }
                            }
                        case "Jeonnam":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.jeonnamFlag.isHidden = false
                                }
                            }
                        case "Jeju":
                            if count >= 3 {
                                DispatchQueue.main.async {
                                    self.jejuFlag.isHidden = false
                                }
                            }
                        default:
                            print("error")
                        }
                    }

                    self.activityIndicator.stopAnimating()
                } catch {
                    print("error")
                }
                
            case .failure(let error):
                print(error)
            }
        }
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
        //.validate(statusCode: 200..<300)
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
                            self.performSegue(withIdentifier: "uploadToLogin", sender: self)
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
                    
                    self.getHistory()

                } catch {
                    print("error")
                }
            case .failure(let error):
                print("Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
}
