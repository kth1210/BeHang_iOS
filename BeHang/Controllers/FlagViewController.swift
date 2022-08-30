//
//  FlagViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit

class FlagViewController: UIViewController {
    @IBOutlet var sharingView: UIView!
    @IBOutlet var shareInstagramButton: UIButton!
    
    @IBOutlet var seoulFlag: UIImageView!
    @IBOutlet var incheonFlag: UIImageView!
    @IBOutlet var daejeonFlag: UIImageView!
    @IBOutlet var daeguFlag: UIImageView!
    @IBOutlet var gwangjuFlag: UIImageView!
    @IBOutlet var busanFlag: UIImageView!
    @IBOutlet var ulsanFlag: UIImageView!
    @IBOutlet var sejongFlag: UIImageView!
    @IBOutlet var gyeonggiFlag: UIImageView!
    @IBOutlet var gangwonFlag: UIImageView!
    @IBOutlet var chungbukFlag: UIImageView!
    @IBOutlet var chungnamFlag: UIImageView!
    @IBOutlet var kyungbukFlag: UIImageView!
    @IBOutlet var kyungnamFlag: UIImageView!
    @IBOutlet var jeonbukFlag: UIImageView!
    @IBOutlet var jeonnamFlag: UIImageView!
    @IBOutlet var jejuFlag: UIImageView!
    
    var flagArr : [UIImageView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        seoulFlag.isHidden = true
        incheonFlag.isHidden = true
        daejeonFlag.isHidden = true
        daeguFlag.isHidden = true
        gwangjuFlag.isHidden = true
        busanFlag.isHidden = true
        ulsanFlag.isHidden = true
        sejongFlag.isHidden = true
        gyeonggiFlag.isHidden = true
        gangwonFlag.isHidden = true
        chungbukFlag.isHidden = true
        chungnamFlag.isHidden = true
        kyungbukFlag.isHidden = true
        kyungnamFlag.isHidden = true
        jeonbukFlag.isHidden = true
        jeonnamFlag.isHidden = true
        jejuFlag.isHidden = true


    }
    
    @IBAction func shareInstagramButtonPressed(_ sender: UIButton) {
        
        if let storyShareURL = URL(string: "instagram-stories://share") {
            if UIApplication.shared.canOpenURL(storyShareURL) {
                let renderer = UIGraphicsImageRenderer(size: sharingView.bounds.size)
                
                let renderImage = renderer.image { _ in
                    sharingView.drawHierarchy(in: sharingView.bounds, afterScreenUpdates: true)
                }
                
                guard let imageData = renderImage.pngData() else {return}
                
                let pasteboardItems : [String:Any] = [
                    "com.instagram.sharedSticker.stickerImage" : imageData,
                    "com.instagram.sharedSticker.backgroundTopColor" : "#636e72",
                    "com.instagram.sharedSticker.backgroundBottomColor" : "#b2becc3"
                ]
                
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate : Date().addingTimeInterval(300)
                ]
                
                UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                
                UIApplication.shared.open(storyShareURL, options: [:], completionHandler: nil)
            } else {
                let alert = UIAlertController(title: "알림", message: "인스타그램이 설치되어 있지 않습니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
