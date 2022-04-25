//
//  TemperatureDetailViewController.swift
//  WeatherGift
//
//  Created by Rosemary Gellene on 4/25/22.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM d"
    return dateFormatter
}()

class TemperatureDetailViewController: UIViewController {
    @IBOutlet weak var shirtImageView: UIImageView!
    @IBOutlet weak var pantsImageView: UIImageView!
    @IBOutlet weak var layersImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    var locationIndex = 0
    var temperatureDetail: TemperatureDetail!
    var locationManager: CLLocationManager!
    var weatherLocations: [WeatherLocation] = []
    var selectedLocationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearUserInterface()
        
        if locationIndex == 0 {
            getLocation()
        }
        
        updateUserInterface()
    }
    
    func clearUserInterface() {
        temperatureLabel.text = ""
        shirtImageView.image = UIImage()
        pantsImageView.image = UIImage()
        layersImageView.image = UIImage()
    }
    
    func updateUserInterface() {
        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
        let weatherLocation = pageViewController.weatherLocations[locationIndex]
        temperatureDetail = TemperatureDetail(name: weatherLocation.name, latitude: weatherLocation.latitude, longitude: weatherLocation.longitude)
        
        //self.temperatureLabel.text = "\(self.temperatureDetail.temperature)°"
//        pageControl.numberOfPages = pageViewController.weatherLocations.count
//        pageControl.currentPage = locationIndex
        temperatureDetail.getData {
            DispatchQueue.main.async {
                self.temperatureLabel.text = "\(self.temperatureDetail.temperature)°"
                //TODO: set images
                if self.temperatureDetail.temperature >= 60 && self.temperatureDetail.temperature <= 150 {
                    self.shirtImageView.image = UIImage(named: "ss")
                    self.pantsImageView.image = UIImage(named: "s")
                } else if self.temperatureDetail.temperature >= 45 && self.temperatureDetail.temperature <= 60 {
                    self.shirtImageView.image = UIImage(named: "ss-ls")
                    self.pantsImageView.image = UIImage(named: "s-p")
                    self.layersImageView.image = UIImage(named: "sw")
                } else {
                    self.shirtImageView.image = UIImage(named: "ss-sw")
                    self.pantsImageView.image = UIImage(named: "p")
                    self.layersImageView.image = UIImage(named: "c")
                }
                
            }
        }
    }

}

extension TemperatureDetailViewController: CLLocationManagerDelegate {

    func getLocation() {
        // Creating a CLLocationManager will automatically check authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("👮‍♀️👮‍♀️ Checking authentication status.")
        handleAuthenticationStatus(status: status)
    }

    func handleAuthenticationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.oneButtonAlert(title: "Location services denied", message: "It may be that parental controls are restricting location use in this app.")
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select 'Settings' below to open device settings and enable location services for this app.")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("DEVELOPER ALERT: Unknown case of status in handleAuthnticationStatus\(status)")
        }
    }

    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("Something went wrong getting the UIApplication.openSettingsURLString")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last ?? CLLocation()
        print("🗺 Current location is \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            var locationName = ""
            if placemarks != nil {
                // get the first placemark
                let placemark = placemarks?.last
                // assign placemark to locationName
                locationName = placemark?.name ?? "Parts Unknown"
            } else {
                print("ERROR: retrieving place.")
                locationName = "Could not find location"
            }
//             Update weatherLocation[0] with the current location so it can be used in updateUserInterface. getLocation only called when locationIndex == 0
            let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
            pageViewController.weatherLocations[self.locationIndex].latitude = currentLocation.coordinate.latitude
            pageViewController.weatherLocations[self.locationIndex].longitude = currentLocation.coordinate.longitude
            pageViewController.weatherLocations[self.locationIndex].name = locationName
            self.updateUserInterface()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription). Failed to get device location.")
    }
}
