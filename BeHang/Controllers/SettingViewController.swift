//
//  SettingViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/08.
//

import UIKit
import KakaoSDKUser

class SettingViewController: UIViewController {
    let settingTitle = ["- 계정 설정", "- 알림 설정", "- 공지사항", "- 약관 및 정책", "- 버전 정보", "- 서비스 문의"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "설정"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    


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

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as? SettingCell else {
            return UITableViewCell()
        }
        cell.settingTitle.text = settingTitle[indexPath.row]
        
        return cell
    }
    
    
}
