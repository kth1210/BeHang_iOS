//
//  SettingViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/08.
//

import UIKit
import KakaoSDKUser

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "설정"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logoutPressed(_ sender: UIButton) {
        UserApi.shared.logout { error in
            if let error = error {
                print(error)
            } else {
                print("logout() success.")
                
                //self.navigationController?.popViewController(animated: true)
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            }
        }
    }
    
    @IBAction func unlinkPressed(_ sender: UIButton) {
        UserApi.shared.unlink { error in
            if let error = error {
                print(error)
            } else {
                print("unlink() success.")
                
                //self.navigationController?.popViewController(animated: true)
                
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            }
        }
    }
    
}
