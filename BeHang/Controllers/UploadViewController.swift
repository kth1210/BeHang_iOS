//
//  UploadViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit

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
        guard let imageData = uploadedImageView.image?.jpegData(compressionQuality: 0.2) else {
            print("등록된 이미지가 없습니다!")
            return
        }
        
        let imageBase64String = imageData.base64EncodedString(options: .lineLength64Characters)
        print(imageBase64String)
        
        
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
