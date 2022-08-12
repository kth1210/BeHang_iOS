//
//  PlaceListViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/30.
//

import UIKit
import Alamofire

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
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        let URL = "https://jsonplaceholder.typicode.com/todos/1"
        print(URL)
        
        AF.request(URL,
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .validate(statusCode: 200..<300)
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data)
                    
                    print(asJSON)
                } catch {
                    print("error")
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
}
