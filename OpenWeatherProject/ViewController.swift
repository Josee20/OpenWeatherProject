//
//  ViewController.swift
//  OpenWeatherProject
//
//  Created by 이동기 on 2022/08/13.
//

import CoreLocation
import UIKit
import OpenWeatherFramework

import Alamofire
import Kingfisher
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windStrengthLabel: UILabel!
    @IBOutlet weak var iconWeatherImageView: UIImageView!
    @IBOutlet weak var saySomethingLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let absoluteTemperature = 273.15
    var weatherInfoList = [WeatherInfoStruct]()
    var temptemp: Double = 0
    
    var currentLatitude: Double = 0
    var currentLongtitude: Double = 0
    
    var currentTime = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        setCornerRadius()
//        showWeatherInfo()
        
        
        checkVersionLocationServiceAuthorization()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일 HH시 mm분"
        dateFormatter.locale = Locale(identifier: "ko-KR")
        timeLabel.text = dateFormatter.string(from: currentTime)
        
        
    }
    
    func setCornerRadius() {
        temperatureLabel.layer.cornerRadius = 10
        temperatureLabel.clipsToBounds = true
        humidityLabel.layer.cornerRadius = 10
        humidityLabel.clipsToBounds = true
        windStrengthLabel.layer.cornerRadius = 10
        windStrengthLabel.clipsToBounds = true
        iconWeatherImageView.layer.cornerRadius = 10
        saySomethingLabel.layer.cornerRadius = 10
        saySomethingLabel.clipsToBounds = true
        
    }
    
    func showWeatherInfo() {
        OpenWeatherAPIManager.shared.requestWeatherData(type: .weather, lat: currentLatitude, lon: currentLongtitude) { json in
            let temp = json["main"]["temp"].doubleValue - self.absoluteTemperature
            let humidity = json["main"]["humidity"].doubleValue
            let windSpeed = json["wind"]["speed"].doubleValue
            let iconImage = json["weather"][0]["icon"].stringValue
            let location = json["name"].stringValue
            
            let findLocation = CLLocation(latitude: self.currentLatitude, longitude: self.currentLongtitude)
            let geocoder = CLGeocoder()
            let locale = Locale(identifier: "Ko-kr") //원하는 언어의 나라 코드를 넣어주시면 됩니다.
            
            geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: {(placemarks, error) in
                if let address: [CLPlacemark] = placemarks {
                    
                    if let name: String = address.last?.name { print(name) } //전체 주소
                    self.locationLabel.text = address.last?.name
                }
            })
            
            let imageURL = URL(string: "\(APIKey.weatherIconKey)\(iconImage)@4x.png")
            let weatherInfo = WeatherInfoStruct(temperature: temp, humidity: humidity, windSpeed: windSpeed, iconImage: iconImage)
            self.weatherInfoList.append(weatherInfo)
            
//            self.locationLabel.text = location
            self.temperatureLabel.text = "  지금은 \(floor(weatherInfo.temperature))°C에요  "
            self.humidityLabel.text = "  \(floor(weatherInfo.humidity))%만큼 습해요  "
            self.windStrengthLabel.text = "  \(floor(weatherInfo.windSpeed))m/s의 바람이 불어요  "
            self.iconWeatherImageView.kf.setImage(with: imageURL)
        }
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        showOpenWeatherAVC(shareHumid: humidityLabel.text!, shareTemp: temperatureLabel.text!, shareLocation: locationLabel.text!)
        print(humidityLabel.text!)
        
        
    }
}

extension ViewController {
    
    func checkVersionLocationServiceAuthorization() {
        let authorizationStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorizationStatus(authorizationStatus)
        } else {
            print("위치서비스가 꺼져있어 권한 요청을 할 수 없습니다")
        }
    }
    
    func checkLocationAuthorizationStatus( _ authorizationStatus: CLAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            print("NOTDETERMINED")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("DENIED")
            showRequestLocationAlert()
        case .authorizedWhenInUse:
            print("WHENINUSE")
            locationManager.startUpdatingLocation()
            print(currentLatitude)
            print(currentLongtitude)
        default:
            print("DEFAULT")
        }
    }
    
    func showRequestLocationAlert() {
        let alert = UIAlertController(title: "위치정보 이용", message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정>개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        
        let moveSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .default)
        
        alert.addAction(moveSetting)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function, "위치를 성공적으로 가져왔습니다")
        
        currentLatitude = locations.last!.coordinate.latitude
        currentLongtitude = locations.last!.coordinate.longitude
        
        

        
        showWeatherInfo()
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치를 찾지 못했습니다")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkVersionLocationServiceAuthorization()
    }
}
