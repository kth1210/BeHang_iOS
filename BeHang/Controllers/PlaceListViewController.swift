//
//  PlaceListViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/30.
//

import UIKit
import Alamofire

class PlaceListViewController: UIViewController {
    @IBOutlet weak var placeSearchBar: UISearchBar!
    
    let confirmButton = UIBarButtonItem(title: "확인", style: .plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "장소 목록"
        
//        self.navigationItem.rightBarButtonItem = confirmButton
//        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: "#455AE4")
        
        placeSearchBar.delegate = self
        placeSearchBar.placeholder = "장소 이름 검색"
        
        self.hideKeyboardWhenTappedAround()
    }
    

    func getPlaceList(keyword: String) {
        let URL = "http://apis.data.go.kr/B551011/KorService/searchKeyword"
        var param: Parameters = [
            "serviceKey" : "A8dJ8nKE9AlL1AWJ8bwxLGO/zRDGpaUHZpxXR2axdgbrLT0uSQ49GSfWi4EtwfnfoFGNLJw6rHLB0ix9Qtl+EQ==",
            "numOfRows" : "10",
            "pageNo" : "1",
            "MobileOS" : "IOS",
            "MobileApp" : "BeHang",
            "_type" : "json",
            "listYN" : "Y",
            "arrange" : "C"
            //"keyword" : "광화문"
        ]
        
        param["keyword"] = keyword

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

extension PlaceListViewController: UISearchBarDelegate {
    
    override var textInputMode: UITextInputMode? {
        if let language = getKeyboardLanguage() {
            for inputMode in UITextInputMode.activeInputModes {
                if inputMode.primaryLanguage! == language {
                    return inputMode
                }
            }
        }
        return super.textInputMode
    }
    
    private func getKeyboardLanguage() -> String? {
        return "ko-KR"
    }
    
    private func dismissKeyboard() {
        placeSearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        
        guard let searchTerm = placeSearchBar.text, searchTerm.count >= 2 else {
            placeSearchBar.text = ""
            placeSearchBar.placeholder = "두 글자 이상 키워드를 입력해주세요."
            return
        }

        getPlaceList(keyword: searchTerm)
        
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardByTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboardByTap() {
        view.endEditing(true)
    }
}
