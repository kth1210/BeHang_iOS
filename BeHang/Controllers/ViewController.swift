//
//  ViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit
import KakaoSDKUser
import Alamofire
import AuthenticationServices

class ViewController: UIViewController {

    @IBOutlet weak var kakaoLoginButton: UIImageView!
    @IBOutlet var appleLoginButton: UIImageView!
    @IBOutlet weak var withoutLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //kakaoLoginButton.layer.cornerRadius = 12
        //appleLoginButton.layer.cornerRadius = 12
        
        withoutLoginButton.layer.addBorder([.bottom], color: UIColor.black, width: 2.0)
        
        let tapKakaoLogin = UITapGestureRecognizer(target: self, action: #selector(loginKakao))
        kakaoLoginButton.addGestureRecognizer(tapKakaoLogin)
        kakaoLoginButton.isUserInteractionEnabled = true
        
        let tapAppleLogin = UITapGestureRecognizer(target: self, action: #selector(loginApple))
        appleLoginButton.addGestureRecognizer(tapAppleLogin)
        appleLoginButton.isUserInteractionEnabled = true
    }
    
    @objc func loginApple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self as ASAuthorizationControllerDelegate
        controller.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
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
                    
                    if UserDefaults.standard.string(forKey: "accessToken") == nil {
                        print("call signup")
                        self.signup(accessToken: accessToken!)
                    } else {
                        print("call login")
                        self.login(accessToken: accessToken!)
                    }
                    
                    
                    guard let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {return}
                    nextVC.modalPresentationStyle = .fullScreen
                    nextVC.modalTransitionStyle = .crossDissolve
                    self.present(nextVC, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func signup(accessToken : String) {
        //let url = "https://ptsv2.com/t/oiexm-1660281750/post"
        let signupUrl = "http://35.247.33.79:8080/v1/social/signup/kakao"
        
        let accessToken = accessToken
        //let refreshToken = refreshToken
       
        
        let header : HTTPHeaders = [
            "Content-Type" : "application/json"
        ]

        let bodyData : Parameters = [
            "accessToken" : accessToken
        ] as Dictionary
        
        
        AF.request(
            signupUrl,
            method: .post,
            parameters: bodyData,
            encoding: JSONEncoding.default,
            headers: header
        )
        .validate(statusCode: 200..<300)
        .responseData { (response) in
            switch response.result {
            case .success:
                print("Success Signup")
                self.login(accessToken: accessToken)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    
    func login(accessToken: String) {
        let loginUrl = "http://35.247.33.79:8080/v1/social/login/kakao"
        print(accessToken)
        let header : HTTPHeaders = [
            "Content-Type" : "application/json"
        ]

        let bodyData : Parameters = [
            "accessToken" : accessToken
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
                    let token = res["accessToken"] as! String
                    
                    UserDefaults.standard.setValue(token, forKey: "accessToken")
                    
                    print(asJSON)
                    print("Success Login")
                    
                    //self.test(accessToken: UserDefaults.standard.string(forKey: "accessToken")!)
                    
                } catch {
                    print("error")
                }

            case .failure(let error):
                print("Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
    
    func test(accessToken: String) {
        
    }
    
    @IBAction func withoutLoginButtonPressed(_ sender: UIButton) {
        guard let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {return}
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.modalTransitionStyle = .crossDissolve
        self.present(nextVC, animated: true, completion: nil)
    }
    
    
}

extension ViewController: ASAuthorizationControllerDelegate {
    // authorization 성공
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        //let a = ASAuthorizationAppleIDProvider()
        //a.getCredentialState(forUserID: <#T##String#>, completion: <#T##(ASAuthorizationAppleIDProvider.CredentialState, Error?) -> Void#>)
    }
    
    // authorization 실패
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
       //
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
