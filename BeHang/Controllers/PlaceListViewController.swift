//
//  PlaceListViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/30.
//

import UIKit

class PlaceListViewController: UIViewController {

    let confirmButton = UIBarButtonItem(title: "확인", style: .plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "장소 목록"
        
        self.navigationItem.rightBarButtonItem = confirmButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: "#455AE4")
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
