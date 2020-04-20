import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {

    let WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "d2b15f38ac237576c7181c22b03c12fb"
    
    let weatherDataModel = WeatherDataModel()
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    func getWeatherData(url: String, parameters: [String : String])
    {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess{
                print("Success!... Got the weather data")
                
                let weatherJSON = JSON(response.result.value!)
                
                print(weatherJSON)
                
                self.updateWeatherData(json: weatherJSON)
                            
            }else{
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    func updateWeatherData(json: JSON){
           let tempResult = json["main"]["temp"].doubleValue
        
            weatherDataModel.temperature = Int(tempResult - 273.15)
        
            weatherDataModel.city = json["name"].stringValue
        
            weatherDataModel.condition = json["weather"][0]["id"].intValue
        
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
             updateUIWithWeatherData()
    }
    
    func updateUIWithWeatherData()
    {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }


    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
     
            print("longitude \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let param : [String : String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: param)
        }
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
        
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredACityName(city: String) {
        
        let param : [String : String] = ["q" : city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: param)
      
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
            
        }
    }
    

    
}


