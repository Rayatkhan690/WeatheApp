//
//  ViewController.swift
//  Breeze Bliss
//
//  Created by Rayat Khan on 29/11/2023
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minimumTempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var descrptionLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    //MARK: - Variables
    var locationManager: CLLocationManager!
    let weatherDataModel = WeatherDataModel()
        
    //MARK: - Constants for openweathermap
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "39702fbf6ac94139452854d574861542"
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        updateCurrentlocationWeather()
    }
    
    func updateCurrentlocationWeather() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //best accuracy for weather apps
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation() //asynchronus method
        }
    }
    
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city,
                                          "appid" : APP_ID ?? ""]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //MARK: - Location Manager protocol methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        locationManager.stopUpdatingLocation()

        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let latitude = String(userLocation.coordinate.latitude)
        let longitude = String(userLocation.coordinate.longitude)
        
        let params : [String : String] = ["lat" : latitude,
                                          "lon" : longitude,
                                          "appid" : APP_ID ?? ""]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        
        let alert = UIAlertController(title: "Warning", message: "Location can not be retrieved.\nPlease check your internet connection.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    //MARK: - NETWORKING
    func getWeatherData(url: String, parameters: [String : String]){
        AF.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                let weatherJSON : JSON = JSON(value)
                self.updateWeatherData(json: weatherJSON)
            case .failure(let error):
                print("Error: \(error)")
                self.cityLabel.text = "Connection issue."
            }
        }
    }
    
    
    
    //MARK: - JSON PARSING
    func updateWeatherData(json: JSON) {
        
        let tempResult = json["main"]["temp"].double
        let minimumTempResult = json["main"]["temp_min"].double
        let humidityResult = json["main"]["humidity"].int
        let weatherIconResult = json["weather"][0]["id"].int
        let descriptionResult = json["weather"][0]["description"].string
        let cityResult = json["name"].string
        let countryResult : String? = json["sys"]["country"].stringValue

        if cityResult == nil {
            showAlert()
            
        } else {
//            print(countryResult)
             
             weatherDataModel.temperature = Int(tempResult! - 273.15) //K - 273.15 = C
             weatherDataModel.minimumTemperature = Int(minimumTempResult! - 273.15)
             weatherDataModel.humidity = humidityResult!
             weatherDataModel.description = descriptionResult!
             weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherIconResult!)
             weatherDataModel.city = cityResult!
             weatherDataModel.country = countryResult!
             
             //update UI with WeatherDataModel values
             updateUIWithWeatherData()
        }
    }
    
    //UI
    func updateUIWithWeatherData() {
        self.temperatureLabel.text = "\(weatherDataModel.temperature)°"
        self.minimumTempLabel.text = "\(weatherDataModel.minimumTemperature)°"
        self.humidityLabel.text = "\(weatherDataModel.humidity) %"
        self.descrptionLabel.text = "\(weatherDataModel.description)"
        if weatherDataModel.description.contains("sky") {
            gifImageLoad(gifFile: "Sky")
        } else if weatherDataModel.description.contains("thunderstorm") {
            gifImageLoad(gifFile: "Thunderstorm")
        } else if weatherDataModel.description.contains("drizzle") {
            gifImageLoad(gifFile: "drizzle")
        } else if weatherDataModel.description.contains("rain") {
            gifImageLoad(gifFile: "rain")
        } else if weatherDataModel.description.contains("snow") {
            gifImageLoad(gifFile: "snow")
        } else if weatherDataModel.description.contains("smoke") {
            gifImageLoad(gifFile: "smoke")
        } else if weatherDataModel.description.contains("haze") {
            gifImageLoad(gifFile: "haze")
        } else if weatherDataModel.description.contains("fog") {
            gifImageLoad(gifFile: "fog")
        } else if weatherDataModel.description.contains("clouds") {
            gifImageLoad(gifFile: "clouds")
        }
        
        self.weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        self.cityLabel.text = "\(weatherDataModel.city)"
        self.countryLabel.text = "\(weatherDataModel.country)"
        
    }
    
    func gifImageLoad(gifFile: String) {
        let imageData = try? Data(contentsOf: Bundle.main.url(forResource: gifFile, withExtension: "gif")!)
            let advTimeGif = UIImage.gifImageWithData(imageData!)
            let imageView2 = UIImageView(image: advTimeGif)
        imageView2.alpha = 0.2
        self.imgBackground.image = imageView2.image
    }
    
    func showAlert() {
            let alertController = UIAlertController(
                title: "Message",
                message: "City not found!. Please enter correct city name.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.updateCurrentlocationWeather()
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    
    
    
    @IBAction func btnSearchIcon(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeCityViewController") as! ChangeCityViewController
        vc.delegate = self
        present(vc, animated: true)
    }
}




