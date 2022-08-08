//
//  MapViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/07/29.
//

import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var tag1: UIButton!
    @IBOutlet weak var tag2: UIButton!
    @IBOutlet weak var tag3: UIButton!
    @IBOutlet weak var tag4: UIButton!
    @IBOutlet weak var tag5: UIButton!
    @IBOutlet weak var tag6: UIButton!
    
    @IBOutlet weak var searchLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        searchLabel.layer.addBorder([.bottom], color: UIColor(hex: "AEAEAE"), width: 1.0)
        
        tag1.layer.cornerRadius = 8
        tag2.layer.cornerRadius = 8
        tag3.layer.cornerRadius = 8
        tag4.layer.cornerRadius = 8
        tag5.layer.cornerRadius = 8
        tag6.layer.cornerRadius = 8
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func tagPressed(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            sender.backgroundColor = UIColor(hex: "#AEAEAE")
        } else {
            sender.isSelected = true
            sender.backgroundColor = UIColor(hex: "#455AE4")
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
