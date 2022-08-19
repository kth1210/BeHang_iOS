//
//  MapViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit

class MapViewController: UIViewController, MTMapViewDelegate {
    
//    @IBOutlet weak var tag1: UIButton!
//    @IBOutlet weak var tag2: UIButton!
//    @IBOutlet weak var tag3: UIButton!
//    @IBOutlet weak var tag4: UIButton!
//    @IBOutlet weak var tag5: UIButton!
//    @IBOutlet weak var tag6: UIButton!
    
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var searchLabel: UILabel!
    
    lazy var list: [PlaceInfo] = {
        var datalist = [PlaceInfo]()
        return datalist
    }()
    
    @IBOutlet var subView: UIView!
    var mapView: MTMapView?
    
    var mapPoint: MTMapPoint?
    var poiItem: MTMapPOIItem?
    
    var latitude: Double = 37.579617
    var longitude: Double = 126.977041
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        searchLabel.layer.addBorder([.bottom], color: UIColor(hex: "AEAEAE"), width: 2.0)
        
//        tag1.layer.cornerRadius = 8
//        tag2.layer.cornerRadius = 8
//        tag3.layer.cornerRadius = 8
//        tag4.layer.cornerRadius = 8
//        tag5.layer.cornerRadius = 8
//        tag6.layer.cornerRadius = 8
        
        self.mapSearchBar.delegate = self
        self.mapSearchBar.searchBarStyle = .minimal
        self.mapSearchBar.placeholder = "장소 이름 검색"
        self.hideKeyboardWhenTappedAround()
        
        
        mapView = MTMapView(frame: subView.frame)
        
        if let mapView = mapView {
            mapView.delegate = self
            mapView.baseMapType = .standard
            
            mapView.currentLocationTrackingMode = .onWithoutHeading
            mapView.showCurrentLocationMarker = true
            
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude)), zoomLevel: 5, animated: true)
            self.view.addSubview(mapView)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        
        print("here")
        makeMarker()
    }
    
    func makeMarker() {
        print("makeMarker")
        var cnt = 0
        
        for item in list {
            let lon = Double(item.mapx!)
            let lat = Double(item.mapy!)
            print(lat!)
            print(lon!)

            self.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: lat!, longitude: lon!))
            
            poiItem = MTMapPOIItem()
            poiItem?.markerType = MTMapPOIItemMarkerType.redPin
            poiItem?.mapPoint = mapPoint
            poiItem?.itemName = item.title
            poiItem?.tag = cnt            
            mapView?.add(poiItem)
            cnt += 1
        }
    }
    
//    @IBAction func tagPressed(_ sender: UIButton) {
//        if sender.isSelected {
//            sender.isSelected = false
//            sender.backgroundColor = UIColor(hex: "#AEAEAE")
//        } else {
//            sender.isSelected = true
//            sender.backgroundColor = UIColor(hex: "#455AE4")
//        }
//    }

    
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
