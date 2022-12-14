//
//  UploadViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit
import Alamofire
import AVFoundation
import Photos

class UploadViewController: UIViewController {

    @IBOutlet weak var selectMent: UILabel!
    @IBOutlet weak var uploadedImageView: UIImageView!
    @IBOutlet weak var selectPlaceButton: UIButton!
    
    @IBOutlet weak var tagButton1: UIButton!    // 편리한 주차
    @IBOutlet weak var tagButton2: UIButton!    // 편리한 대중교통
    @IBOutlet weak var tagButton3: UIButton!    // 아이와 함께
    @IBOutlet weak var tagButton4: UIButton!    // 실내
    @IBOutlet weak var tagButton5: UIButton!    // 연인과 함께
    @IBOutlet weak var tagButton6: UIButton!    // 반려견과 함께
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let overlayView = UIView()
    
    let imagePickerController = UIImagePickerController()
    lazy var registerButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "등록", style: .plain, target: self, action: #selector(registerButtonPressed))
        return button
    }()
    
    
    // 선택한 장소의 정보
    var selectedPlaceInfo = PlaceInfo()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectPlaceButton.layer.cornerRadius = 15
        selectPlaceButton.backgroundColor = UIColor(hex: "#455AE4")
        tagButton1.layer.cornerRadius = 15
        tagButton2.layer.cornerRadius = 15
        tagButton3.layer.cornerRadius = 15
        tagButton4.layer.cornerRadius = 15
        tagButton5.layer.cornerRadius = 15
        tagButton6.layer.cornerRadius = 15
        
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        overlayView.frame = self.view.bounds
        overlayView.center = self.view.center
        overlayView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        
        self.view.addSubview(self.overlayView)
        self.view.addSubview(self.activityIndicator)
        
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "새 게시물"
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        self.navigationItem.rightBarButtonItem = registerButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: "#455AE4")
        
        overlayView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectPhotoPressed))
        uploadedImageView.addGestureRecognizer(tapGesture)
        uploadedImageView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        //self.tabBarController?.tabBar.isHidden = true
        
        if let placeName = selectedPlaceInfo.title {
            self.selectPlaceButton.setTitle(placeName, for: .normal)
        }
    }
    
    @objc func selectPhotoPressed() {
        let requiredAccessLevel: PHAccessLevel = .readWrite
        PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                print("notDetermined")
            case .restricted:
                print("restricted")
            case .denied:
                print("denied")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "알림", message: "앨범 접근 권한을 확인해주세요.", preferredStyle: UIAlertController.Style.alert)

                    let confirm = UIAlertAction(title: "설정", style: .default) { _ in
                        guard let url = URL(string: UIApplication.openSettingsURLString) else {return}
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                    let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

                    alert.addAction(cancel)
                    alert.addAction(confirm)

                    self.present(alert, animated: true, completion: nil)
                }
            case .authorized:
                print("authorized")
                DispatchQueue.main.async {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    self.present(imagePicker, animated: true)
                }
                
            case .limited:
                print("limited")
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "알림", message: "원활한 서비스 이용을 위해 모든 사진에 대한 접근을 허용해주세요.", preferredStyle: UIAlertController.Style.alert)

                    let confirm = UIAlertAction(title: "설정", style: .default) { _ in
                        guard let url = URL(string: UIApplication.openSettingsURLString) else {return}
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                    let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

                    alert.addAction(cancel)
                    alert.addAction(confirm)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
//        present(imagePicker, animated: true)
        
//        if status == PHAuthorizationStatus.authorized {
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = .photoLibrary
//            present(imagePicker, animated: true)
//        } else {
//            let alert = UIAlertController(title: "알림", message: "앨범 접근 권한을 확인해주세요.", preferredStyle: UIAlertController.Style.alert)
//
//            let confirm = UIAlertAction(title: "설정", style: .default) { _ in
//                guard let url = URL(string: UIApplication.openSettingsURLString) else {return}
//                if UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url)
//                }
//            }
//            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
//
//            alert.addAction(cancel)
//            alert.addAction(confirm)
//
//            DispatchQueue.main.async {
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
        
    }
    
    @objc func registerButtonPressed() {
        //uploadedImageView.image?.resize(newWidth: 300).jpegData(compressionQuality: 1.0)
        guard let imageData = uploadedImageView.image?.resize(newWidth: 400).jpegData(compressionQuality: 1.0) else {
            let alert = UIAlertController(title: "알림", message: "이미지를 업로드하시기 바랍니다.", preferredStyle: UIAlertController.Style.alert)
            let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: nil)
            
            alert.addAction(confirm)
            self.present(alert, animated: true)
            return
        }
        
        if selectedPlaceInfo.title == nil {
            let alert = UIAlertController(title: "알림", message: "장소를 선택하시기 바랍니다.", preferredStyle: UIAlertController.Style.alert)
            let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: nil)
            
            alert.addAction(confirm)
            self.present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(title: "알림", message: "업로드 하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { _ in
            self.uploadPost(imageData: imageData)
        }
        let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    
    func uploadPost(imageData: Data) {
        overlayView.isHidden = false
        activityIndicator.startAnimating()
        
        let url = "http://\(urlConstants.release)/posts"

        let header : HTTPHeaders = [
            "Content-Type" : "multipart/form-data",
            "X-AUTH-TOKEN" : UserDefaults.standard.string(forKey: "accessToken")!
        ]
        
        let place: [String: Any] = [
            "address" : selectedPlaceInfo.address ?? "",
            "contentId" : selectedPlaceInfo.contentId ?? "",
            "areaCode" : selectedPlaceInfo.areaCode ?? "",
            "mapX" : selectedPlaceInfo.mapx ?? "",
            "mapY" : selectedPlaceInfo.mapy ?? "",
            "name" : selectedPlaceInfo.title ?? "",
            "phoneNumber" : selectedPlaceInfo.tel ?? ""
        ]
        let name = selectedPlaceInfo.title ?? ""
        
        let tag: [String: Any] = [
            "comfortablePubTransit": tagButton2.isSelected,
            "convenientParking": tagButton1.isSelected,
            "indoor": tagButton4.isSelected,
            "withChild": tagButton3.isSelected,
            "withLover": tagButton5.isSelected,
            "withMyDog": tagButton6.isSelected
        ]
        var arrFormData = [String:Any]()

        arrFormData["place"] = place
        arrFormData["tag"] = tag
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: arrFormData, options: .prettyPrinted)

            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "file", fileName: "\(name).jpeg", mimeType: "image/jpeg")
                multipartFormData.append(jsonData, withName: "postRequestDto", mimeType: "application/json")
            }, to: url, method: .post, headers: header)
            //.validate(statusCode: 200..<300)
            .responseData { response in
                print(response)

                switch response.result {
                case .success(let data):
                    do {
                        let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
 
                        let code = asJSON["code"] as! Int

                        if code == -1011 {
                            self.reissue(imageData: imageData)
                            return
                        }
                        print("success upload")
                        self.navigationController?.popViewController(animated: true)
                    } catch {
                        print("error")
                    }
                    
                case .failure(let error):
                    print("upload failed")
                    print(error)
                }
            }
        } catch {
            print("error")
        }
    }

    
    @IBAction func tagButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            sender.backgroundColor = UIColor(named: "unselectedColor")

        } else {
            sender.isSelected = true
            sender.backgroundColor = UIColor(named: "mainColor")
        }

    }
    
    func reissue(imageData: Data) {
        let loginUrl = "http://\(urlConstants.release)/reissue"

        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")

        let header : HTTPHeaders = [
            "Content-Type" : "application/json",
            //"X-AUTH-TOKEN" : accessToken!
        ]
        
        let bodyData : Parameters = [
            "accessToken" : accessToken!,
            "refreshToken" : refreshToken!
        ] as Dictionary
        
        AF.request(
            loginUrl,
            method: .post,
            parameters: bodyData,
            encoding: JSONEncoding.default,
            headers: header
        )
        //.validate(statusCode: 200..<300)
        .responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let code = asJSON["code"] as! Int
                    
                    // 자체 토큰이 만료
                    if code == -1014 {
                        // 토큰 재발급
                        let alert = UIAlertController(title: "알림", message: "로그인이 만료되었습니다. 다시 로그인해주세요.", preferredStyle: UIAlertController.Style.alert)
                        let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { _ in
                            UserDefaults.standard.setValue("none", forKey: "login")
                            UserDefaults.standard.setValue(false, forKey: "isLogin")
                            self.performSegue(withIdentifier: "uploadToLogin", sender: self)
                        }
                    
                        alert.addAction(confirm)
                        self.present(alert, animated: true)
                        
                        return
                    }

                    let res = asJSON["data"] as! NSDictionary

                    // 자체 토큰 재발급
                    let xToken = res["accessToken"] as! String
                    let refreshToken = res["refreshToken"] as! String

                    UserDefaults.standard.setValue(xToken, forKey: "accessToken")
                    UserDefaults.standard.setValue(refreshToken, forKey: "refreshToken")
                    
                    print("토큰 재발급")
                    print(asJSON)
                    
                    self.uploadPost(imageData: imageData)

                } catch {
                    print("error")
                }
            case .failure(let error):
                print("Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }

}

extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.uploadedImageView.image = image
            self.selectMent.text = ""
        }
        dismiss(animated: true, completion: nil)
    }
}

extension UIColor {
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}


