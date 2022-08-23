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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        shareInstagramButton.layer.borderWidth = 1.5
//        shareInstagramButton.layer.borderColor = UIColor.black.cgColor
//        shareInstagramButton.layer.cornerRadius = shareInstagramButton.frame.height / 2
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
