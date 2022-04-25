//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by Rosemary Gellene on 4/25/22.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter
}()

class WeatherDetail: WeatherLocation {
    
    private struct Result: Codable {
        var timezone: String
        var current: Current
    }
    
    private struct Current: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Weather: Codable {
        var description: String
    }
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var summary = ""
    
    func getData(completed: @escaping () -> ()) {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=imperial&appid=\(APIkeys.openWeatherKey)"
        print("We are accessing the url \(urlString)")
        guard let url = URL(string: urlString) else {
            print("ERROR: Could not create a url from \(urlString)")
            completed()
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            do {
                let result = try JSONDecoder().decode(Result.self, from: data!)
                self.timezone = result.timezone
                self.currentTime = result.current.dt
                self.temperature = Int(result.current.temp.rounded())
                self.summary = result.current.weather[0].description
            } catch {
                print("JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
    }
    
//    private func shirtforTemp(temp: Double) -> String {
//        var shirtImage = ""
//        switch temp {
//        case 60...150:
//            shirtImage = "ss"
//        case 45...60:
//            shirtImage = "ss-ls"
//        case -35...45:
//            shirtImage = "ss-sw"
//        default:
//            shirtImage = ""
//        }
//        return shirtImage
//    }
    
//    private func pantsforTemp(temp: Double) -> String {
//        var pantsImage = ""
//        switch temp {
//        case 60...150:
//            pantsImage = "s"
//        case 45...60:
//            pantsImage = "s-p"
//        case -35...45:
//            pantsImage = "p"
//        default:
//            pantsImage = ""
//        }
//        return pantsImage
//    }
//
//    private func layersforTemp(temp: Double) -> String {
//        var layersImage = ""
//        switch temp {
//        case 60...150:
//            layersImage = ""
//        case 45...60:
//            layersImage = "sw"
//        case -35...45:
//            layersImage = "c"
//        default:
//            layersImage = ""
//        }
//        return layersImage
//    }
}

