//
//  SettingViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/08.
//

import UIKit
import KakaoSDKUser

class SettingViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let settingTitle = ["- 계정 설정", "- 개인정보처리약관", "- 버전 정보", "- 서비스 문의"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "설정"
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        tableView.isScrollEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        tableView.deselectRow(at: indexPath, animated: true)
        switch index {
        case 0:
            let nowLogin = UserDefaults.standard.string(forKey: "login")
            
            if nowLogin == "none" {
                let alert = UIAlertController(title: "알림", message: "로그인이 필요한 서비스입니다.", preferredStyle: UIAlertController.Style.alert)
                let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: nil)
            
                alert.addAction(confirm)
                self.present(alert, animated: true)
            } else {
                guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountSettingViewController") as? AccountSettingViewController else {return}
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            
        case 1:
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "PolicyViewController") as? PolicyViewController else {return}
            self.navigationController?.pushViewController(nextVC, animated: true)
        case 2:
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "VersionViewController") as? VersionViewController else {return}
            self.navigationController?.pushViewController(nextVC, animated: true)
        case 3:            
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactViewController") as? ContactViewController else {return}
            self.navigationController?.pushViewController(nextVC, animated: true)
        default:
            print("error")
        }
    }
    
}
