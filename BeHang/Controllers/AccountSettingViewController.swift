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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "계정 설정"
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""

        tableView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func logoutKakao() {
        let url = "http://\(urlConstants.release)/social/logout/kakao"
        
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
            case .success:
                print("logout Success")
                UserDefaults.standard.setValue(false, forKey: "isLogin")
                UserDefaults.standard.setValue("none", forKey: "login")
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func withdrawalKakao() {
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
                    }
                    
                    UserDefaults.standard.setValue(false, forKey: "isLogin")
                    UserDefaults.standard.setValue("none", forKey: "login")
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                    UserDefaults.standard.removeObject(forKey: "signupKakao")
                    UserDefaults.standard.removeObject(forKey: "kakaoAccessToken")
                    
//                    for key in UserDefaults.standard.dictionaryRepresentation().keys {
//                        UserDefaults.standard.removeObject(forKey: key.description)
//                    }
                    
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
            case .success:
                print("logout Success")
                UserDefaults.standard.setValue(false, forKey: "isLogin")
                UserDefaults.standard.setValue("none", forKey: "login")
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func withdrawalApple() {
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
            case .success:
                print("apple withdrawal success")
                
                UserDefaults.standard.setValue(false, forKey: "isLogin")
                UserDefaults.standard.setValue("none", forKey: "login")
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                UserDefaults.standard.removeObject(forKey: "signupApple")
                UserDefaults.standard.removeObject(forKey: "appleName")
                
//                for key in UserDefaults.standard.dictionaryRepresentation().keys {
//                    UserDefaults.standard.removeObject(forKey: key.description)
//                }
                
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            case .failure(let error):
                print(error)
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
        
        switch index {
        case 0:
            // 로그아웃
            print("로그아웃")
            let alert = UIAlertController(title: "로그아웃", message: "로그아웃 이후 어플리케이션이 종료됩니다.", preferredStyle: UIAlertController.Style.alert)
            let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { _ in
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
