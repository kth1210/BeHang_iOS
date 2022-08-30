//
//  MapSearchViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/19.
//

import UIKit
import Alamofire

class MapSearchViewController: UIViewController {
    @IBOutlet var mapSearchBar: UISearchBar!
    @IBOutlet var mapTableView: UITableView!
    @IBOutlet var searchLabel: UILabel!
    @IBOutlet var toMapButton: UIButton!
    
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    lazy var list: [PlaceInfo] = {
        var datalist = [PlaceInfo]()
        return datalist
    }()
    
    var firstSearch: String?
    
    var pageNo = 0
    var moreData = true
    var selectPlace = PlaceInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchLabel.layer.addBorder([.bottom], color: UIColor(hex: "AEAEAE"), width: 2.0)
        
        mapSearchBar.delegate = self
        self.mapSearchBar.searchBarStyle = .minimal
        mapSearchBar.placeholder = "장소 이름 검색"
        
        self.hideKeyboardWhenTappedAround()
        
        self.view.addSubview(self.activityIndicator)
        
        mapTableView.dataSource = self
        
        self.mapSearchBar.text = firstSearch!
        
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.mapTableView.center
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.startAnimating()
        getPlaceList(keyword: firstSearch!)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    
    @IBAction func toMap(_ sender: UIButton) {
        let index = self.navigationController?.viewControllers.count
        let preVC = self.navigationController?.viewControllers[index! - 2]

        guard let vc = preVC as? MapViewController else {
            print("fail")
            return
        }
        
        vc.list = self.list
        //vc.selectedPlaceInfo = self.selectPlace
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func getPlaceList(keyword: String) {
        self.pageNo += 1
        
        let URL = "http://apis.data.go.kr/B551011/KorService/searchKeyword"
        var param: Parameters = [
            "serviceKey" : "A8dJ8nKE9AlL1AWJ8bwxLGO/zRDGpaUHZpxXR2axdgbrLT0uSQ49GSfWi4EtwfnfoFGNLJw6rHLB0ix9Qtl+EQ==",
            "numOfRows" : "10",
            "MobileOS" : "IOS",
            "MobileApp" : "BeHang",
            "_type" : "json",
            "listYN" : "Y",
            "arrange" : "O"
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
                        self.mapTableView.tableFooterView?.isHidden = true
                        self.mapTableView.reloadData()
                        return
                    }
                    let body = res["body"] as! NSDictionary
                    guard let items = body["items"] as? NSDictionary else {
                        self.mapSearchBar.text = ""
                        self.mapSearchBar.placeholder = "검색 결과가 없습니다."
                        self.activityIndicator.stopAnimating()
                        self.mapTableView.reloadData()
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
                    self.mapTableView.reloadData()
                    self.mapTableView.tableFooterView?.isHidden = true
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
            self.getPlaceList(keyword: self.mapSearchBar.text!)
        })
    }
    

}


extension MapSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapListCell", for: indexPath) as! ListCell

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
            
            self.mapTableView.tableFooterView = spinner
            self.mapTableView.tableFooterView?.isHidden = false
            
            getMore()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectPlace = list[indexPath.row]
        
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController else {return}
        nextVC.image = selectPlace.thumbnailImg
        nextVC.placeName = selectPlace.title
        // 같은 장소 이미지
        nextVC.contentId = Int(selectPlace.contentId ?? "1")
        nextVC.isMap = true
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}





extension MapSearchViewController: UISearchBarDelegate {
    
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
        mapSearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        
        guard let searchTerm = mapSearchBar.text, searchTerm.count >= 2 else {
            mapSearchBar.text = ""
            mapSearchBar.placeholder = "두 글자 이상 키워드를 입력해주세요."
            return
        }
        self.list.removeAll()
        self.pageNo = 0
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.mapTableView.center
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.startAnimating()
        getPlaceList(keyword: searchTerm)
    }
}
