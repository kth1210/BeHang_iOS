//
//  UploadViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit
import Alamofire

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
        
        
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "새 게시물"
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "이전"
        
        self.navigationItem.rightBarButtonItem = registerButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: "#455AE4")
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectPhotoPressed))
        uploadedImageView.addGestureRecognizer(tapGesture)
        uploadedImageView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        //self.tabBarController?.tabBar.isHidden = true
        
        if let placeName = selectedPlaceInfo.title {
            print(placeName)
            //self.selectPlaceButton.titleLabel?.text = placeName
            self.selectPlaceButton.setTitle(placeName, for: .normal)
        }
    }
    
    @objc func selectPhotoPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    @objc func registerButtonPressed() {
        
        guard let imageData = uploadedImageView.image?.jpegData(compressionQuality: 0.5) else {
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
        let url = "http://35.247.33.79:8080/posts"

        let header : HTTPHeaders = [
            "Content-Type" : "multipart/form-data",
            "X-AUTH-TOKEN" : UserDefaults.standard.string(forKey: "accessToken")!
        ]
        
        let place: [String: Any] = [
            "address" : selectedPlaceInfo.address ?? "",
            "contentId" : selectedPlaceInfo.contentId ?? "",
            "mapx" : selectedPlaceInfo.mapx ?? "",
            "mapy" : selectedPlaceInfo.mapy ?? "",
            "name" : selectedPlaceInfo.title ?? "",
            "phoneNumber" : selectedPlaceInfo.tel ?? ""
        ]
        let name = selectedPlaceInfo.title ?? ""
        
        let tag: [String: Any] = [
            "comfortablePubTransit": tagButton1.isSelected,
            "convenientParking": tagButton2.isSelected,
            "indoor": tagButton3.isSelected,
            "withChild": tagButton4.isSelected,
            "withLover": tagButton5.isSelected,
            "withMyDog": tagButton6.isSelected
        ]
        var arrFormData = [String:Any]()

        arrFormData["place"] = place
        arrFormData["tag"] = tag
        print(arrFormData)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: arrFormData, options: .prettyPrinted)

            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "file", fileName: "\(name).jpeg", mimeType: "image/jpeg")
                multipartFormData.append(jsonData, withName: "postRequestDto", mimeType: "application/json")
            }, to: url, method: .post, headers: header)
            .validate(statusCode: 200..<300)
            .responseData { response in
                print(response)

                switch response.result {
                case .success:
                    print("success upload")
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("success failed")
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


