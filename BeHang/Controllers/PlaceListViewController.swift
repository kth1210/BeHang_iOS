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
        //let URL = "https://jsonplaceholder.typicode.com/todos/1"
        //let URL = "http://35.227.155.59:8080/hello"
        let URL = "http://apis.data.go.kr/B551011/KorService/searchKeyword"
        let param: Parameters = [
            "serviceKey" : "A8dJ8nKE9AlL1AWJ8bwxLGO/zRDGpaUHZpxXR2axdgbrLT0uSQ49GSfWi4EtwfnfoFGNLJw6rHLB0ix9Qtl+EQ==",
            "numOfRows" : "10",
            "pageNo" : "1",
            "MobileOS" : "IOS",
            "MobileApp" : "BeHang",
            "_type" : "json",
            "listYN" : "Y",
            "arrange" : "C",
            "keyword" : "광화문"
        ]

        AF.request(URL,
                   method: .get,
                   parameters: param,
                   encoding: URLEncoding.queryString,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .validate(statusCode: 200..<300)
//        .response { response in
//            debugPrint(response)
//        }
//        .responseJSON { data in
//            print(data)
//        }
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary

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
