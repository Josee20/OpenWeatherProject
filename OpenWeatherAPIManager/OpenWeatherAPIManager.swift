//
//  OpenWeatherAPIManager.swift
//  OpenWeatherProject
//
//  Created by 이동기 on 2022/08/14.
//

import Foundation

import Alamofire
import SwiftyJSON

class OpenWeatherAPIManager {
    
    private init() { }
    
    static let shared = OpenWeatherAPIManager()
    
    func requestWeatherData(type: EndPoint, lat: Double, lon: Double, completionHandler: @escaping (JSON) ->()) {
        let url = "\(type.requestURL)lat=\(lat)&lon=\(lon)&appid=\(APIKey.openWeatherKey)"
        
        AF.request(url, method: .get).validate(statusCode: 200...500).responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
//                print("JSON: \(json)")
                
                let statusCode = response.response?.statusCode ?? 400
                
                if statusCode == 200 {
                    completionHandler(json)
                } else {
                    print("에러가 발생했습니다")
                }
                
            case .failure(let error):
                print(error)
            }
        }
    } 
}
