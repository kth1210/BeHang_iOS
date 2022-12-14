//
//  FlagViewController.swift
//  BeHang
//
//  Created by κΉνν on 2022/07/29.
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
                let alert = UIAlertController(title: "μλ¦Ό", message: "μΈμ€νκ·Έλ¨μ΄ μ€μΉλμ΄ μμ§ μμ΅λλ€.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "νμΈ", style: .default, handler: nil)
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
                // νμκ°μ μ±κ³΅νλ©΄ μ ν ν ν°, μ΄λ¦μΌλ‘ λ‘κ·ΈμΈ
                do{
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let code = asJSON["code"] as! Int
                    if code == -1011 {
                        // ν ν° μ¬λ°κΈ
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
                    
                    // μμ²΄ ν ν°μ΄ λ§λ£
                    if code == -1014 {
                        // ν ν° μ¬λ°κΈ
                        let alert = UIAlertController(title: "μλ¦Ό", message: "λ‘κ·ΈμΈμ΄ λ§λ£λμμ΅λλ€. λ€μ λ‘κ·ΈμΈν΄μ£ΌμΈμ.", preferredStyle: UIAlertController.Style.alert)
                        let confirm = UIAlertAction(title: "νμΈ", style: UIAlertAction.Style.default) { _ in
                            UserDefaults.standard.setValue("none", forKey: "login")
                            UserDefaults.standard.setValue(false, forKey: "isLogin")
                            self.performSegue(withIdentifier: "uploadToLogin", sender: self)
                        }
                    
                        alert.addAction(confirm)
                        self.present(alert, animated: true)
                        
                        return
                    }

                    let res = asJSON["data"] as! NSDictionary

                    // μμ²΄ ν ν° μ¬λ°κΈ
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
