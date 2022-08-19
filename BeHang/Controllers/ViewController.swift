//
//  ViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit
import KakaoSDKUser
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var kakaoLoginButton: UIImageView!
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var withoutLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //kakaoLoginButton.layer.cornerRadius = 12
        appleLoginButton.layer.cornerRadius = 12
        
        withoutLoginButton.layer.addBorder([.bottom], color: UIColor.black, width: 2.0)
        
        let tapKakaoLogin = UITapGestureRecognizer(target: self, action: #selector(loginKakao))
        kakaoLoginButton.addGestureRecognizer(tapKakaoLogin)
        kakaoLoginButton.isUserInteractionEnabled = true
    }

    @objc func loginKakao() {
        print("loginKakao() called")
        
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print("error")
                    print(error)
                } else {
                    print("loginWithKakaoTalk() success")
                    
                    
                    _ = oauthToken
                    let accessToken = oauthToken?.accessToken
                    
                    //self.getUserInfo()
                    //self.postTest(accessToken: accessToken!)
                    
                    guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {return}
                    self.navigationController?.pushViewController(nextVC, animated: true)
                    
                }
            }
        }
    }
    
    func postTest(accessToken : String) {
        //let url = "https://ptsv2.com/t/oiexm-1660281750/post"
        let url = "http://35.227.155.59:8080/v1/social/login/kakao"
        let accessToken = accessToken
        //let refreshToken = refreshToken
        
        let header : HTTPHeaders = [
            "Content-Type" : "application/json"
        ]

        let bodyData : Parameters = [
            "accessToken" : accessToken
        ] as Dictionary
        
        
        AF.request(
            url,
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
                    let token = res["accessToken"] as! String
                    
                    self.test(accessToken: token)
                    
                    
                    print(asJSON)
                    
                } catch {
                    print("error")
                }

            case .failure(let error):
                print("Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
    
    func test(accessToken: String) {
        let url = "http://35.227.155.59:8080/post"
        print("Token: \(accessToken)")
        
        let param: Parameters = [
            //"accessToken" : accessToken
            "place" : [
                "name" : "우리집",
                "address" : "수성구 어쩌고",
                "phoneNumber" : "01062214335",
                "contentID" : 12345678,
                "mapx" : 123.123123,
                "mapy" : 123.123123
            ],
            "postImage" : "메롱메롱",
            "tag" : [
                "convenientParking" : true,
                "comfortablePubtransit" : false,
                "withChild" : true,
                "indoor" : true,
                "suddenRain" : false,
                "withMyDog" : true
            ],
            "userId" : 1
        ]
        
        AF.request(url,
                   method: .post,
                   parameters: param,
                   encoding: JSONEncoding.default,
                   //encoding: URLEncoding.queryString,
                   //headers: ["Content-Type":"application/json", "Accept":"application/json"])
                   headers: ["X-AUTH-TOKEN" : accessToken])
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

extension ViewController {
    
    private func getUserInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                print(error)
            } else {
                print("me() success")
                
                let nickname = user?.kakaoAccount?.profile?.nickname
                
                guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {return}

                nextVC.nickname = nickname

                self.navigationController?.pushViewController(nextVC, animated: true)
                
            }
        }
    }
}
