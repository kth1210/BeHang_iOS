//
//  LaunchViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/20.
//

import UIKit
import Alamofire

class LaunchViewController: UIViewController {
    
    //private let appDelegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            if UserDefaults.standard.bool(forKey: "isLogin") {
                // 이전에 로그인 했으면
                self.reissue()
            } else {
                // 이전에 로그인 안했으면 로그인 화면으로
                self.presentToLogin()
            }
        }
    }
    

    
    private func presentToMain() {
        guard let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {return}
        mainVC.modalPresentationStyle = .fullScreen
        mainVC.modalTransitionStyle = .crossDissolve
        self.present(mainVC, animated: true, completion: nil)
    }
    
    
    private func presentToLogin() {
        guard let loginVC = UIStoryboard(name: "LoginView", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? ViewController else {return}
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.modalTransitionStyle = .crossDissolve
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func reissue() {
        print("call reissue")
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

                    let res = asJSON["data"] as! NSDictionary

                    // 자체 토큰 재발급
                    let xToken = res["accessToken"] as! String
                    let refreshToken = res["refreshToken"] as! String

                    UserDefaults.standard.setValue(xToken, forKey: "accessToken")
                    UserDefaults.standard.setValue(refreshToken, forKey: "refreshToken")
                    UserDefaults.standard.setValue(true, forKey: "isLogin")

                    self.presentToMain()

                } catch {
                    print("error")
                }
            case .failure(let error):
                print("Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }

}
