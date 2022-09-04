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
    
    lazy var confirmButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(confirmButtonPressed))
        return button
    }()
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // API JSON 데이터 배열로 받아오기
    lazy var list: [PlaceInfo] = {
        var datalist = [PlaceInfo]()
        return datalist
    }()
    
    // 받아오는 페이지 번호
    var pageNo = 0
    // 더 받아올 데이터가 있는지?
    var moreData = true
    // 선택한 장소 정보
    var selectPlace = PlaceInfo()

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationController 설정
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "장소 목록"
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "이전"
                
        self.navigationItem.rightBarButtonItem = self.confirmButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: "#455AE4")
        
        // searchBar 설정
        placeSearchBar.delegate = self
        placeSearchBar.placeholder = "장소 이름 검색"
        
        // 다른 곳 탭하면 키보드 내리기
        self.hideKeyboardWhenTappedAround()
        
        
        self.view.addSubview(self.activityIndicator)
        
        
        tableView.dataSource = self
    }
    
    // 장소 고르고 확인 버튼 눌렀을 때
    @objc func confirmButtonPressed() {
        let index = self.navigationController?.viewControllers.count
        let preVC = self.navigationController?.viewControllers[index! - 2]

        guard let vc = preVC as? UploadViewController else {
            print("fail")
            return
        }
        
        vc.selectedPlaceInfo = self.selectPlace
        
        self.navigationController?.popViewController(animated: true)
    }

    // API 호출해서 데이터 배열에 받아오기
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
            "arrange" : "O"
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
                    
                    guard let res = asJSON["response"] as? NSDictionary else {
                        self.moreData = false
                        self.tableView.tableFooterView?.isHidden = true
                        self.tableView.reloadData()
                        return
                    }
                    let body = res["body"] as! NSDictionary
                    guard let items = body["items"] as? NSDictionary else {
                        self.placeSearchBar.text = ""
                        self.placeSearchBar.placeholder = "검색 결과가 없습니다."
                        self.activityIndicator.stopAnimating()
                        self.tableView.reloadData()
                        return
                    }
                    let item = items["item"] as! NSArray
                    let numOfRows = body["numOfRows"] as! Int
                    
                    if numOfRows != 10 {
                        self.moreData = false
                    }

                    for row in item {
                        let r = row as! NSDictionary
            
                        let placeData = PlaceInfo()
                        placeData.address = r["addr1"] as? String
                        placeData.contentId = r["contentid"] as? String
                        placeData.areaCode = r["areacode"] as? String
                        placeData.mapx = r["mapx"] as? String
                        placeData.mapy = r["mapy"] as? String
                        placeData.title = r["title"] as? String
                        placeData.tel = r["tel"] as? String
                        placeData.thumbnail = r["firstimage"] as? String
                        
                        if placeData.thumbnail != "" {
                            let url: URL! = Foundation.URL(string: placeData.thumbnail!)
                            let imageData = try! Data(contentsOf: url)
                            placeData.thumbnailImg = UIImage(data: imageData)
                        }
                        
                        self.list.append(placeData)
                    }                    
                    self.tableView.reloadData()
                    self.tableView.tableFooterView?.isHidden = true
                    self.activityIndicator.stopAnimating()
                    
                    print(asJSON)
                } catch {
                    print("error")
                }

            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            self.getPlaceList(keyword: self.placeSearchBar.text!)
        })
    }
}

//MARK: - Setting TableView

extension PlaceListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListCell

        cell.placeAddress.text = list[indexPath.row].address
        cell.placeName.text = list[indexPath.row].title
        cell.placeImg.image = list[indexPath.row].thumbnailImg
        
        cell.placeAddress.sizeToFit()
        cell.placeName.sizeToFit()

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex && moreData{
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
            
            getMore()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectPlace = list[indexPath.row]
    }
    
}

//MARK: - UISearchBarDelegate
// 한글 키보드 먼저 나오게 설정, 검색 눌렀을 때 키보드 내려가게 설정
// 2글자 이상 검색 가능

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
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.tableView.center
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.startAnimating()
        getPlaceList(keyword: searchTerm)
    }
}

//MARK: - 키보드 내려가게하기

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
