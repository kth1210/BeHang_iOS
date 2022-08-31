//
//  ChangeProfileViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/28.
//

import UIKit
import Alamofire

class ChangeProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickName: UITextField!
    
    let imagePickerController = UIImagePickerController()
    lazy var changeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "변경", style: .plain, target: self, action: #selector(changeButtonPressed))
        return button
    }()
    
    var image: UIImage?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.image = image
        nickName.text = name

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectPhotoPressed))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "프로필 수정"
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        self.navigationItem.rightBarButtonItem = changeButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: "#455AE4")
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.tintColor = UIColor(named: "unselectedColor")
        profileImage.clipsToBounds = true
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

    @objc func changeButtonPressed() {
        
        guard let changeName = self.nickName.text, changeName.count >= 2 else {
            let alert = UIAlertController(title: "알림", message: "닉네임을 두 글자 이상 입력해주세요.", preferredStyle: UIAlertController.Style.alert)
            let confirm = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: nil)
            
            alert.addAction(confirm)
            self.present(alert, animated: true)
            
            return
        }
        
        if profileImage.image != image || changeName != name {
            let url = "http://35.247.33.79/users/profile/me"

            let header : HTTPHeaders = [
                "Content-Type" : "multipart/form-data",
                "X-AUTH-TOKEN" : UserDefaults.standard.string(forKey: "accessToken")!
            ]
            
            let imageData = profileImage.image?.jpegData(compressionQuality: 0.5)
            
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData!, withName: "file", fileName: "\(changeName).jpeg", mimeType: "image/jpeg")
                multipartFormData.append(changeName.data(using: .utf8)!, withName: "nickName")
            }, to: url, method: .patch, headers: header)
            //.validate(statusCode: 200..<300)
            .responseData { response in
                print(response)
                
                switch response.result {
                case .success(let data):
                    do {
                        let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                        let code = asJSON["code"] as! Int
                        print(code)
                        if code == -1014 {
                            self.reissue()
                            return
                        }
                        
                        print("success change")
                        
                        let index = self.navigationController?.viewControllers.count
                        let preVC = self.navigationController?.viewControllers[index! - 2]

                        guard let vc = preVC as? UserViewController else {
                            print("fail")
                            return
                        }
                        
//                        vc.selectedPlaceInfo = self.selectPlace
                        vc.userName.text = changeName
                        vc.profileImage.image = self.profileImage.image
                        
                        self.navigationController?.popViewController(animated: true)
                    } catch {
                        print("error")
                    }
                    
                case .failure(let error):
                    print("upload failed")
                    print(error)
                }
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func reissue() {
        let loginUrl = "http://35.247.33.79/reissue"

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

                    let res = asJSON["data"] as! NSDictionary

                    // 자체 토큰 재발급
                    let xToken = res["accessToken"] as! String
                    let refreshToken = res["refreshToken"] as! String

                    UserDefaults.standard.setValue(xToken, forKey: "accessToken")
                    UserDefaults.standard.setValue(refreshToken, forKey: "refreshToken")
                    
                    print("토큰 재발급")
                    print(asJSON)
                    
                    self.changeButtonPressed()

                } catch {
                    print("error")
                }
            case .failure(let error):
                print("Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
    
    
    
    @objc func selectPhotoPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

}

extension ChangeProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension ChangeProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nickName.resignFirstResponder()
        return true
    }
    
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
        nickName.resignFirstResponder()
    }
    
}
