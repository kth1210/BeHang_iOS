//
//  AccountSettingViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/25.
//

import UIKit

class AccountSettingViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let accountSettingTitle = ["- 로그아웃", "- 회원탈퇴"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.isScrollEnabled = false
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
        case 1:
            // 회원탈퇴
            print("회원탈퇴")
        default:
            print("error")
        }
    }
}
