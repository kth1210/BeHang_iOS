//
//  ContactViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/09/06.
//

import UIKit

class ContactViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "서비스 문의"
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}
