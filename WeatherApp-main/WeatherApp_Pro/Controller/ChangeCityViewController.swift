//
//  ChangeCityViewController.swift
//  Breeze Bliss
//
//  Created by Rayat Khan on 29/11/2023.
//

import UIKit
import CoreLocation

//protocol here
protocol ChangeCityDelegate {
    func userEnteredANewCityName(city : String)
}

class ChangeCityViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate {
    @IBOutlet weak var getWeatherButton: UIButton!
    @IBOutlet weak var changeCityTextField: UITextField!
    @IBOutlet weak var searchCity: UISearchBar!
    @IBOutlet weak var errorLabel: UILabel!
    
    var delegate : ChangeCityDelegate?
    let weatherDataModel = WeatherDataModel()

    var cities = ["Abc", "Bgd", "Cfggg", "Deutschland", "Estonia"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherButton.layer.cornerRadius = 11
        navigationController?.navigationBar.isHidden = true
        //search bar delegate
        searchCity.delegate? = self
        searchCity.returnKeyType = .done
        changeCityTextField.delegate? = self
        
        changeCityTextField.layer.cornerRadius = 12
        changeCityTextField.layer.masksToBounds = true
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func getWeatherPressed(_ sender: Any) {
        let cityName = changeCityTextField.text!
        delegate?.userEnteredANewCityName(city: cityName)
        self.dismiss(animated: true, completion: nil)
    }
}
