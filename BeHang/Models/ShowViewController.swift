//
//  ShowViewController.swift
//  BeHang
//
//  Created by 김태현 on 2022/09/05.
//

import Foundation
import UIKit

let story = UIStoryboard(name: "NetworkView", bundle: nil)

func showNetworkVCOnRoot() {
    DispatchQueue.main.async {
        guard let networkViewController = story.instantiateViewController(withIdentifier: "NetworkViewController") as? NetworkViewController else {print("storyboard error")
            return}
        networkViewController.modalPresentationStyle = .fullScreen
        //UIApplication.shared.windows.first?.rootViewController?.show(networkViewController, sender: nil)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        window?.rootViewController?.show(networkViewController, sender: nil)
        
        print("showNetworkVCOnRoot()")
    }
}
