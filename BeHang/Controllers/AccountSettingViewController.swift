//
//  AccountSettingViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/25.
//

import UIKit
import Alamofire
import KakaoSDKAuth
import KakaoSDKUser

class AccountSettingViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let accountSettingTitle = ["- 로그아웃", "- 회원탈퇴"]
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var reissueCase = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "계정 설정"
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = .black
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        
        tableView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func logoutKakao() {
        print("logoutKakao()")
        self.reissueCase = 0
        
        let url = "http://\(urlConstants.release)/social/logout/kakao"
        
        let xToken = UserDefaults.standard.string(forKey: "accessToken")!
        let kakaoAccessToken = UserDefaults.standard.string(forKey: "kakaoAccessToken")!
        print(kakaoAccessToken)
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : xToken
        ]
        print(xToken)
        
        let bodyData : Parameters = [
            "socialAccessToken" : kakaoAccessToken
        ]
        
        AF.request(url,
                   method: .post,
                   parameters: bodyData,
                   //encoding: URLEncoding.queryString,
                   encoding: JSONEncoding.default,
                   headers: header
        )
        //.validate(statusCode: 200..<300)
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    debugPrint(data)
                    print("------")
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    print(asJSON)
                    let code = asJSON["code"] as! Int

                    if code == -1005 {
                        print("kakao refresh")
                        AuthApi.shared.refreshToken { oauthToken, error in

                            let accessToken = oauthToken?.accessToken
                            UserDefaults.standard.setValue(accessToken, forKey: "kakaoAccessToken")

                            self.logoutKakao()
                            return
                        }
                    } else if code == -1011 {
                        print("call reissue")
                        self.reissue()
                        return
                    }
                    
                    print("logout Success")
                    UserDefaults.standard.setValue(false, forKey: "isLogin")
                    UserDefaults.standard.setValue("none", forKey: "login")
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                    
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                } catch {
                    print("logout error")
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func withdrawalKakao() {
        self.reissueCase = 1
        
        let url = "http://\(urlConstants.release)/social/withdrawal/kakao"
        
        let xToken = UserDefaults.standard.string(forKey: "accessToken")!
        let kakaoAccessToken = UserDefaults.standard.string(forKey: "kakaoAccessToken")!
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : xToken
        ]
        
        let bodyData : Parameters = [
            "socialAccessToken" : kakaoAccessToken
        ]
        
        
        AF.request(url,
                   method: .post,
                   parameters: bodyData,
                   //encoding: URLEncoding.queryString,
                   encoding: JSONEncoding.default,
                   headers: header
        )
        //.validate(statusCode: 200..<300)
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                print("withdrawal Success")
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    print(asJSON)
                    let code = asJSON["code"] as! Int
                    
                    if code == -1005 {
                        AuthApi.shared.refreshToken { oauthToken, error in
                            
                            let accessToken = oauthToken?.accessToken
                            UserDefaults.standard.setValue(accessToken, forKey: "kakaoAccessToken")
                            
                            self.withdrawalKakao()
                            return
                        }
                    } else if code == -1011 {
                        print("call reissue")
                        self.reissue()
                        return
                    }
                    
                    UserDefaults.standard.setValue(false, forKey: "isLogin")
                    UserDefaults.standard.setValue("none", forKey: "login")
                    UserDefaults.standard.setValue(false, forKey: "signupKakao")
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                    UserDefaults.standard.removeObject(forKey: "kakaoAccessToken")
                    
                    
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                    
                } catch {
                    print("error")
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func logoutApple() {
        self.reissueCase = 2
        
        let url = "http://\(urlConstants.release)/social/logout/apple"
        
        let xToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : xToken
        ]
        
        
        AF.request(url,
                   method: .post,
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
                    print(asJSON)
                    let code = asJSON["code"] as! Int
                    
                    if code == -1011 {
                        print("call reissue")
                        self.reissue()
                        return
                    }
                    
                    print("logout Success")
                    UserDefaults.standard.setValue(false, forKey: "isLogin")
                    UserDefaults.standard.setValue("none", forKey: "login")
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                    
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                    
                } catch {
                    print("error")
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func withdrawalApple() {
        self.reissueCase = 3
        
        let url = "http://\(urlConstants.release)/social/withdrawal/apple"
        
        let xToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : xToken
        ]
        
        
        AF.request(url,
                   method: .post,
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
                print("apple withdrawal success")
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    print(asJSON)
                    let code = asJSON["code"] as! Int
                    
                    if code == -1011 {
                        print("call reissue")
                        self.reissue()
                        return
                    }
                    UserDefaults.standard.setValue(false, forKey: "isLogin")
                    print(UserDefaults.standard.bool(forKey: "isLogin"))
                    UserDefaults.standard.setValue("none", forKey: "login")
                    UserDefaults.standard.setValue(false, forKey: "signupApple")
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    UserDefaults.standard.removeObject(forKey: "refreshToken")

                    
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                    
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
                            self.performSegue(withIdentifier: "accountToLogin", sender: self)
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
                    
                    switch self.reissueCase {
                    case 0:
                        print("recall logoutkakao()")
                        self.logoutKakao()
                    case 1:
                        print("recall withdrawalKakao()")
                        self.withdrawalKakao()
                    case 2:
                        print("recall logoutApple()")
                        self.logoutApple()
                    case 3:
                        print("withdrawalApple()")
                        self.withdrawalApple()
                    default:
                        print("error")
                        return
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

extension AccountSettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountSettingTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as? SettingCell else {
            return UITableViewCell()
        }
        cell.settingTitle.text = accountSettingTitle[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        tableView.deselectRow(at: indexPath, animated: true)
        switch index {
        case 0:
            // 로그아웃
            print("로그아웃")
            let alert = UIAlertController(title: "로그아웃", message: "로그아웃 이후 어플리케이션이 종료됩니다.", preferredStyle: UIAlertController.Style.alert)
            let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { _ in
                self.activityIndicator.startAnimating()
                let login = UserDefaults.standard.string(forKey: "login")
                if login == "kakao"{
                    self.logoutKakao()
                } else if login == "apple" {
                    self.logoutApple()
                }
                
            }
            let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
            
            alert.addAction(confirm)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        case 1:
            // 회원탈퇴
            print("회원탈퇴")
            
            let alert = UIAlertController(title: "⚠️ 회원탈퇴 ⚠️", message: "정말로 탈퇴하시겠습니까? \n(사용자의 모든 정보가 삭제됩니다.)", preferredStyle: UIAlertController.Style.alert)
            let confirm = UIAlertAction(title: "탈퇴", style: UIAlertAction.Style.destructive) { _ in
                self.activityIndicator.startAnimating()
                let login = UserDefaults.standard.string(forKey: "login")
                if login == "kakao"{
                    self.withdrawalKakao()
                } else if login == "apple" {
                    self.withdrawalApple()
                }
            }
            let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
            
            alert.addAction(confirm)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        default:
            print("error")
        }
    }
}
