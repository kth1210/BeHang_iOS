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
    @IBOutlet weak var tableView: UITableView!
    
    let confirmButton = UIBarButtonItem(title: "확인", style: .plain, target: nil, action: nil)
    var pageNo = 0
    lazy var list: [PlaceInfo] = {
        var datalist = [PlaceInfo]()
        return datalist
    }()

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
        
        
        tableView.dataSource = self
    }
    

    func getPlaceList(keyword: String) {
        self.pageNo += 1
        
        let URL = "http://apis.data.go.kr/B551011/KorService/searchKeyword"
        var param: Parameters = [
            "serviceKey" : "A8dJ8nKE9AlL1AWJ8bwxLGO/zRDGpaUHZpxXR2axdgbrLT0uSQ49GSfWi4EtwfnfoFGNLJw6rHLB0ix9Qtl+EQ==",
            "numOfRows" : "10",
            //"pageNo" : "1",
            "MobileOS" : "IOS",
            "MobileApp" : "BeHang",
            "_type" : "json",
            "listYN" : "Y",
            "arrange" : "P"
            //"keyword" : "광화문"
        ]
        
        param["pageNo"] = pageNo
        param["keyword"] = keyword
        
        AF.request(URL,
                   method: .get,
                   parameters: param,
                   encoding: URLEncoding.queryString,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .validate(statusCode: 200..<300)
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    
                    let res = asJSON["response"] as! NSDictionary
                    let body = res["body"] as! NSDictionary
                    guard let items = body["items"] as? NSDictionary else {
                        self.placeSearchBar.text = ""
                        self.placeSearchBar.placeholder = "검색 결과가 없습니다."
                        self.tableView.reloadData()
                        return
                    }
                    let item = items["item"] as! NSArray
                    
                    for row in item {
                        let r = row as! NSDictionary
                        
                        let placeData = PlaceInfo()
                        
                        placeData.address = r["addr1"] as? String
                        placeData.contentId = r["contentId"] as? String
                        placeData.mapx = r["mapx"] as? String
                        placeData.mapy = r["mapy"] as? String
                        placeData.title = r["title"] as? String
                        placeData.thumbnailImg = r["firstimage"] as? String
                        
                        self.list.append(placeData)
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }

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

extension PlaceListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListCell

        cell.placeAddress.text = list[indexPath.row].address
        cell.placeName.text = list[indexPath.row].title

        let imgURL: URL! = URL(string: list[indexPath.row].thumbnailImg!)
        let imageData = try! Data(contentsOf: imgURL)
        cell.placeImg.image = UIImage(data: imageData)

        cell.placeAddress.sizeToFit()
        cell.placeName.sizeToFit()

        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height {

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
        self.list.removeAll()
        self.pageNo = 0
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
