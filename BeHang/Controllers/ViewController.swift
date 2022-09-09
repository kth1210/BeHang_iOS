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
import AVFAudio

class ViewController: UIViewController {
    
    @IBOutlet weak var kakaoLoginButton: UIImageView!
    @IBOutlet var appleLoginButton: UIImageView!
    @IBOutlet weak var withoutLoginButton: UIButton!
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let overlayView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        overlayView.frame = view.frame
        overlayView.center = view.center
        self.view.addSubview(overlayView)
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        overlayView.isHidden = true
        
        withoutLoginButton.layer.addBorder([.bottom], color: UIColor.black, width: 2.0)
        
        let tapKakaoLogin = UITapGestureRecognizer(target: self, action: #selector(loginKakaoPressed))
        kakaoLoginButton.addGestureRecognizer(tapKakaoLogin)
        kakaoLoginButton.isUserInteractionEnabled = true
        
        let tapAppleLogin = UITapGestureRecognizer(target: self, action: #selector(loginApplePressed))
        appleLoginButton.addGestureRecognizer(tapAppleLogin)
        appleLoginButton.isUserInteractionEnabled = true
    }
    
    @IBAction func unwindToLaunch (segue: UIStoryboardSegue){
        
    }
    
    //MARK: - Kakao Login
    
    // 카카오 로그인 버튼 눌렀을 때
    @objc func loginKakaoPressed() {
        print("loginKakao() called")
        
        // 카카오톡으로 로그인 가능한지 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print("error")
                    print(error)
                } else {
                    print("loginWithKakaoTalk() success")
                    
                    _ = oauthToken
                    let accessToken = oauthToken?.accessToken
                    //let refreshToken = oauthToken?.refreshToken
                    UserDefaults.standard.setValue(accessToken, forKey: "kakaoAccessToken")
                    
                    if UserDefaults.standard.bool(forKey: "signupKakao") {
                        // 카카오로 회원가입한 적이 있으면 토큰 받아온거로 로그인
                        print("call login")
                        self.kakaoLogin(accessToken: accessToken!)
                    } else {
                        // 카카오로 회원가입한 적이 없으면 토큰 받아온거로 회원가입
                        print("call signup")
                        self.kakaoSignup(accessToken: accessToken!)
                    }
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    print(error)
                } else {
                    print("loginWithKakaoAccount() success")
                    
                    _ = oauthToken
                    let accessToken = oauthToken?.accessToken
                    //let refreshToken = oauthToken?.refreshToken
                    UserDefaults.standard.setValue(accessToken, forKey: "kakaoAccessToken")
                    
                    if UserDefaults.standard.bool(forKey: "signupKakao") {
                        // 카카오로 회원가입한 적이 있으면 토큰 받아온거로 로그인
                        print("call login")
                        self.kakaoLogin(accessToken: accessToken!)
                    } else {
                        // 카카오로 회원가입한 적이 없으면 토큰 받아온거로 회원가입
                        print("call signup")
                        self.kakaoSignup(accessToken: accessToken!)
                    }
                }
            }
        }
    }
    
    // 카카오 토큰으로 회원가입
    func kakaoSignup(accessToken : String) {
        print("start kakao signup")
        let signupUrl = "http://\(urlConstants.release)/social/signup/kakao"
        
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
        //.validate(statusCode: 200..<300)
        .responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let code = asJSON["code"] as! Int
                    print(asJSON)
                    
                    // 가입 했던 유저
                    if code == -1006 {
                        print("이미 가입했던 유저")
                        self.kakaoLogin(accessToken: accessToken)
                        return
                    }
                    
                    UserDefaults.standard.setValue(true, forKey: "signupKakao")
                    self.kakaoLogin(accessToken: accessToken)
                    
                } catch {
                    print("sign up error")
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    
    func kakaoLogin(accessToken: String) {
        print("start kakao login")
        self.activityIndicator.startAnimating()
        self.overlayView.isHidden = false
        
        let loginUrl = "http://\(urlConstants.release)/social/login/kakao"
        
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
                    
                    // 자체 토큰 발급
                    let xToken = res["accessToken"] as! String
                    let refreshToken = res["refreshToken"] as! String
                    
                    UserDefaults.standard.setValue(xToken, forKey: "accessToken")
                    UserDefaults.standard.setValue(refreshToken, forKey: "refreshToken")
                    UserDefaults.standard.setValue(true, forKey: "isLogin")
                    UserDefaults.standard.setValue("kakao", forKey: "login")
                    
                    print("Success Login")
                    
                    self.overlayView.isHidden = true
                    self.activityIndicator.stopAnimating()
                    
                    // 메인 화면으로 이동
                    guard let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {return}
                    nextVC.modalPresentationStyle = .fullScreen
                    nextVC.modalTransitionStyle = .crossDissolve
                    self.present(nextVC, animated: true, completion: nil)
                    
                } catch {
                    print("error")
                }
            case .failure(let error):
                print("Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
    
    //MARK: - Apple Login
    
    @objc func loginApplePressed() {
        print("loginApplePressed")
        
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self as ASAuthorizationControllerDelegate
        controller.presentationContextProvider = self as ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
    }
    
    func appleSignup(nickName: String, userId: String) {
        print("appleSignup")
        
        let signupUrl = "http://\(urlConstants.release)/social/signup/apple"
        
        // 회원가입할 때 userName 등록 (한번 밖에 안옴)
        
        
        let header : HTTPHeaders = [
            "Content-Type" : "application/json"
        ]
        
        let bodyData : Parameters = [
            "nickName" : nickName,
            "socialId" : userId
        ] as Dictionary
        
        
        AF.request(
            signupUrl,
            method: .post,
            parameters: bodyData,
            encoding: JSONEncoding.default,
            headers: header
        )
        //.validate(statusCode: 200..<300)
        .responseData { (response) in
            switch response.result {
            case .success(let data):
                // 회원가입 성공하면 애플 토큰, 이름으로 로그인
                print("Success Signup")
                do{
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let code = asJSON["code"] as! Int
                    
                    // 가입 했던 유저
                    if code == -1006 {
                        print("이미 가입했던 유저")
                        self.appleLogin(userId: userId)
                        return
                    }
                    
                    UserDefaults.standard.setValue(true, forKey: "signupApple")
                    
                    self.appleLogin(userId: userId)
                } catch {
                    print("error")
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func appleLogin(userId: String) {
        print("appleLogin")
        self.activityIndicator.startAnimating()
        self.overlayView.isHidden = false
        
        let loginUrl = "http://\(urlConstants.release)/social/login/apple"
        
        let header : HTTPHeaders = [
            "Content-Type" : "application/json"
        ]
        
        
        let bodyData : Parameters = [
            "socialId" : userId
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
                    
                    // 자체 토큰 발급
                    let xToken = res["accessToken"] as! String
                    let refreshToken = res["refreshToken"] as! String
                    
                    UserDefaults.standard.setValue(xToken, forKey: "accessToken")
                    UserDefaults.standard.setValue(refreshToken, forKey: "refreshToken")
                    UserDefaults.standard.setValue(true, forKey: "isLogin")
                    UserDefaults.standard.setValue("apple", forKey: "login")
                    
                    print("Success apple Login")
                    
                    self.overlayView.isHidden = true
                    self.activityIndicator.stopAnimating()
                    
                    // 메인 화면으로 이동
                    guard let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {return}
                    nextVC.modalPresentationStyle = .fullScreen
                    nextVC.modalTransitionStyle = .crossDissolve
                    self.present(nextVC, animated: true, completion: nil)
                    
                } catch {
                    print("error")
                }
            case .failure(let error):
                print("Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
    
    //MARK: - Unless Login
    
    // 로그인 없이 서비스 접속
    @IBAction func withoutLoginButtonPressed(_ sender: UIButton) {
        // isLogin == false
        UserDefaults.standard.setValue("none", forKey: "login")
        guard let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {return}
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.modalTransitionStyle = .crossDissolve
        self.present(nextVC, animated: true, completion: nil)
    }
    
}

//MARK: - Apple Authorization

extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    // authorization 성공
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let userName = (appleIDCredential.fullName?.familyName ?? "") + (appleIDCredential.fullName?.givenName ?? "")
            //            let identity = appleIDCredential.identityToken
            //            let id_token = String(data: identity!, encoding: .utf8)
            //            let autho = appleIDCredential.authorizationCode
            //            let code = String(data: autho!, encoding: .utf8)
            
            
            
            print(userIdentifier)
            print(userName)
            
            
            
            if UserDefaults.standard.bool(forKey: "signupApple") {
                // apple 계정으로 회원가입한 적이 있으면
                self.appleLogin(userId: userIdentifier)
            } else {
                // apple 계정으로 회원가입한 적이 없으면
                if userName == "" {
                    self.appleSignup(nickName: "User", userId: userIdentifier)
                } else {
                    self.appleSignup(nickName: userName, userId: userIdentifier)
                }
                
            }
            
        }
    }
    
    // authorization 실패
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("authorization Error: \(error)")
        let alert = UIAlertController(title: "알림", message: "Apple authorization 실패", preferredStyle: UIAlertController.Style.alert)
        let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(confirm)
        self.present(alert, animated: true)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


//
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
