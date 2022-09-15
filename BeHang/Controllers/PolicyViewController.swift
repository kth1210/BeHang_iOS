//
//  PolicyViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/09/05.
//

import UIKit

class PolicyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "개인정보처리약관"
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }


}
