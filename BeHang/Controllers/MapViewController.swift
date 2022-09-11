//
//  MapViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit
import CoreLocation
import Alamofire

class MapViewController: UIViewController, MTMapViewDelegate, CLLocationManagerDelegate {
    
//    @IBOutlet weak var tag1: UIButton!
//    @IBOutlet weak var tag2: UIButton!
//    @IBOutlet weak var tag3: UIButton!
//    @IBOutlet weak var tag4: UIButton!
//    @IBOutlet weak var tag5: UIButton!
//    @IBOutlet weak var tag6: UIButton!
    
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var nearButton: UIButton!
    @IBOutlet var subView: UIView!
    
    lazy var list: [PlaceInfo] = {
        var datalist = [PlaceInfo]()
        return datalist
    }()
    
    var mapView: MTMapView?
    
    var mapPoint: MTMapPoint?
    var poiItem: MTMapPOIItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        searchLabel.layer.addBorder([.bottom], color: UIColor(hex: "AEAEAE"), width: 2.0)
        
        //buttonView.layer.addBorder([.top, .left, .right, .bottom], color: UIColor(named: "mainColor")!, width: 1.5)
        buttonView.layer.cornerRadius = buttonView.frame.width / 2
        buttonView.clipsToBounds = true
        
        self.mapSearchBar.delegate = self
        self.mapSearchBar.searchBarStyle = .minimal
        self.mapSearchBar.placeholder = "장소 이름 검색"
        self.hideKeyboardWhenTappedAround()
        
        
        
        mapView = MTMapView(frame: subView.frame)
        
        if let mapView = mapView {
            mapView.delegate = self
            mapView.baseMapType = .standard

            self.view.addSubview(mapView)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.view.bringSubviewToFront(buttonView)
        
        mapView?.removeAllPOIItems()
        makeMarker()

        setMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setMap()
    }
    
    func setMap() {
        print("setMap")

        mapView?.fitAreaToShowAllPOIItems()
    }
    
    func makeMarker() {
        //mapView?.removeAllPOIItems()
        print("makeMarker")

        var cnt = 0

        if list.count == 0 {
            return
        }

        for item in list {
            let lon = Double(item.mapx!)
            let lat = Double(item.mapy!)

            self.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: lat!, longitude: lon!))

            poiItem = MTMapPOIItem()
            poiItem?.markerType = MTMapPOIItemMarkerType.redPin
            poiItem?.mapPoint = mapPoint
            poiItem?.itemName = item.title
            poiItem?.tag = cnt
            mapView?.add(poiItem)
            cnt += 1
        }
        setMap()
        list.removeAll()
    }


    @IBAction func nearButtonPressed(_ sender: UIButton) {
        mapView?.removeAllPOIItems()
        mapSearchBar.text = ""
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        
        let coor = locationManager.location?.coordinate
        let latitude = coor?.latitude
        let longitude = coor?.longitude
        
        locationManager.stopUpdatingLocation()
        
        self.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude!, longitude: longitude!))
        
        getNearPlace(mapX: String(longitude!), mapY: String(latitude!))
        
        poiItem = MTMapPOIItem()
        poiItem?.markerType = MTMapPOIItemMarkerType.yellowPin
        poiItem?.mapPoint = mapPoint
        poiItem?.itemName = "현위치"
        mapView?.add(poiItem)
    }
    
    func getNearPlace(mapX: String, mapY: String) {
        let URL = "http://apis.data.go.kr/B551011/KorService/locationBasedList"
        var param: Parameters = [
            "serviceKey" : urlConstants.serviceKey,
            "numOfRows" : "10",
            "pageNo" : "1",
            "MobileOS" : "IOS",
            "MobileApp" : "BeHang",
            "_type" : "json",
            "listYN" : "Y",
            "arrange" : "E",
            "radius" : "5000"
        ]
        param["mapX"] = mapX
        param["mapY"] = mapY
        
        
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
                        return
                    }
                    let body = res["body"] as! NSDictionary
                    guard let items = body["items"] as? NSDictionary else {
                        return
                    }
                    let item = items["item"] as! NSArray
                    
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
                        
//                        if placeData.thumbnail != "" {
//                            let url: URL! = Foundation.URL(string: placeData.thumbnail!)
//                            let imageData = try! Data(contentsOf: url)
//                            placeData.thumbnailImg = UIImage(data: imageData)
//                        }
                        
                        self.list.append(placeData)
                    }
                    self.makeMarker()
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




extension MapViewController: UISearchBarDelegate {
    
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
        
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "MapSearchViewController") as? MapSearchViewController else {return}
        nextVC.firstSearch = searchTerm
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}





//MARK: - layer에 밑줄 넣기 extension

extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}
