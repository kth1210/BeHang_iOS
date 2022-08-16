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
                    let refreshToken = oauthToken?.refreshToken
                    
                    //self.getUserInfo()\
                    self.postTest(accessToken: accessToken!, refreshToken: refreshToken!)
                    
                    guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {return}
                    self.navigationController?.pushViewController(nextVC, animated: true)
                    
                }
            }
        }
    }
    
    func postTest(accessToken : String, refreshToken : String) {
        //let url = "https://ptsv2.com/t/oiexm-1660281750/post"
        let url = "http://35.227.155.59:8080/hello"
        let accessToken = accessToken
        let refreshToken = refreshToken
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "LoginToken")
        request.timeoutInterval = 10
        
        let params = ["accessToken":accessToken, "refreshToken":refreshToken] as Dictionary
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        
        AF.request(request).responseString { (response) in
            switch response.result {
            case .success:
                print("post 성공")
            case .failure(let error):
                print("Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
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
