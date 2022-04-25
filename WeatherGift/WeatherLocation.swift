//
//  WeatherLocation.swift
//  WeatherGift
//
//  Created by Rosemary Gellene on 4/25/22.
//

import Foundation

class WeatherLocation: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
}
