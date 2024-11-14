//
//  PokePin.swift
//  PokemonGo
//
//  Created by Santiago Pisconte  on 14/11/24.
//

import Foundation
import UIKit
import MapKit

class PokePin:NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var pokemon:Pokemon
    
    init(coord: CLLocationCoordinate2D, pokemon:Pokemon) {
        self.coordinate = coord
        self.pokemon = pokemon
    }
}
