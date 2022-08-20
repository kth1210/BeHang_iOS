//
//  LaunchViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/20.
//

import UIKit

class LaunchViewController: UIViewController {
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if self.appDelegate?.isLogin == true {
                print("true")
                self.presentToMain()
            } else {
                print("false")
                self.presentToLogin()
            }
        }
    }
    
    private func presentToMain() {
        guard let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {return}
        mainVC.modalPresentationStyle = .fullScreen
        mainVC.modalTransitionStyle = .crossDissolve
        self.present(mainVC, animated: true, completion: nil)
//        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {
//            print("nextVC 실패")
//            return}
//        print("nextVC 성공")
//        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    private func presentToLogin() {
        //guard let loginVC = UIStoryboard(name: "LoginView", bundle: nil).instantiateViewController(withIdentifier: "LoginNavigationController") as? UINavigationController else {return}
        guard let loginVC = UIStoryboard(name: "LoginView", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? ViewController else {return}
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.modalTransitionStyle = .crossDissolve
        self.present(loginVC, animated: true, completion: nil)
//        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? ViewController else {
//            print("loginviewcon 어쩌고 실패")
//            return
//        }
//        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    


}
