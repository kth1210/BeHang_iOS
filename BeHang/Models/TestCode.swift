//
//  TestCode.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/24.
//

import Foundation
import Alamofire

class TestCode {
    func getPost() {
        let url = "http://35.247.33.79:8080/post/1"
        let access = UserDefaults.standard.string(forKey: "accessToken")!
        
        let header : HTTPHeaders = [
            "X-AUTH-TOKEN" : access
        ]
        
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: JSONEncoding.default,
                   headers: header
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let res = asJSON["data"] as! NSDictionary
                    let img = res["imageFile"] as! String
                    
                    if let data = Data(base64Encoded: img, options: .ignoreUnknownCharacters) {
                        let decodedImg = UIImage(data: data)
                        
                    }
                    
                    
                    print("Get Post")
                    print(asJSON)
                } catch {
                    print("error")
                }
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    func users() {
        let url = "http://35.247.33.79:8080/v1/users"
        let access = UserDefaults.standard.string(forKey: "accessToken")!
        
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: JSONEncoding.default,
                   //encoding: URLEncoding.queryString,
                   //headers: ["Content-Type":"application/json", "Accept":"application/json"])
                   headers: ["X-AUTH-TOKEN" : access])
        .validate(statusCode: 200..<300)
        .responseData { response in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let asJSON = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    
                    
                    print("userList result")
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
