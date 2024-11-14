//
//  ViewController.swift
//  PokemonGo
//
//  Created by Santiago Pisconte  on 12/11/24.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var ubicacion = CLLocationManager()
    var contActualizaciones = 0
    var pokemons:[Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ubicacion.delegate = self
        pokemons = obtenerPokemon()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            setup()
        } else {
            ubicacion.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func centrarTapped(_ sender: Any) {
        if let coord = ubicacion.location?.coordinate{
            let region = MKCoordinateRegion(center: coord, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            setup()
        }
    }
    
    func setup(){
        mapView.delegate = self
        mapView.showsUserLocation = true
        ubicacion.startUpdatingLocation()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            if let coord = self.ubicacion.location?.coordinate {
//                    let pin = MKPointAnnotation()
//                    pin.coordinate = coord
                let pokemon = self.pokemons[Int(arc4random_uniform(UInt32(self.pokemons.count)))]
                let pin = PokePin(coord: coord, pokemon: pokemon)
                let randomLat = (Double(arc4random_uniform(200)) - 100.0) / 5000.0
                let randomLon = (Double(arc4random_uniform(200)) - 100.0) / 5000.0
                pin.coordinate.latitude += randomLat
                pin.coordinate.longitude += randomLon
                self.mapView.addAnnotation(pin)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{
            let pinview = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pinview.image = UIImage(named: "player")
            var frame = pinview.frame
            frame.size.height = 50
            frame.size.width = 50
            pinview.frame = frame
            return pinview
        }
        
        let pinview = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
//        pinview.image = UIImage(named: "mew")
        let pokemon = (annotation as! PokePin).pokemon
        pinview.image = UIImage(named: pokemon.imagenNombre!)
        var frame = pinview.frame
        frame.size.height = 50
        frame.size.width = 50
        pinview.frame = frame
        return pinview
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        if view.annotation is MKUserLocation{
            return
        }
        let region = MKCoordinateRegion.init(center: (view.annotation?.coordinate)!, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (Timer) in
            if let coord = self.ubicacion.location?.coordinate{
                let pokemon = (view.annotation as! PokePin).pokemon
                if mapView.visibleMapRect.contains(MKMapPoint(coord)){
                    print("Puede atrapar el pokemon")
                    
                    if pokemon.atrapado {
                        let alertaVC = UIAlertController(
                            title: "Ya tienes a \(pokemon.nombre!)",
                            message: "Ya tienes \(pokemon.contador) de este Pokémon. ¿Aún así deseas capturarlo?",
                            preferredStyle: .alert
                        )
                        
                        let siAccion = UIAlertAction(title: "Sí", style: .default) { _ in
                            pokemon.contador += 1
                            (UIApplication.shared.delegate as! AppDelegate).saveContext()
                            mapView.removeAnnotation(view.annotation!)
                            self.mostrarAlertaExito(pokemon)
                        }
                        
                        let noAccion = UIAlertAction(title: "No", style: .cancel, handler: nil)
                        alertaVC.addAction(siAccion)
                        alertaVC.addAction(noAccion)
                        self.present(alertaVC, animated: true, completion: nil)
                        
                    } else {
                        pokemon.atrapado = true
                        pokemon.contador = 1
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        mapView.removeAnnotation(view.annotation!)
                        self.mostrarAlertaExito(pokemon)
                    }
                    
                } else {
                    print("No se puede atrapar el pokemon")
                    let alertaVC = UIAlertController(title: "Upss. Está muy lejos", message: "No se puede atrapar el pokemon (\(pokemon.nombre!)). Acerquese más", preferredStyle: .alert)
                    let okAccion = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertaVC.addAction(okAccion)
                    self.present(alertaVC, animated: true, completion: nil)
                }
            }
        }
    }

    
    func mostrarAlertaExito(_ pokemon: Pokemon) {
        let alertaVC = UIAlertController(title: "¡Felicidades!", message: "Atrapaste el pokemon (\(pokemon.nombre!))", preferredStyle: .alert)
        let pokedexAccion = UIAlertAction(title: "Ver Pokedex", style: .default) { _ in
            self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
        }
        let okAccion = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertaVC.addAction(pokedexAccion)
        alertaVC.addAction(okAccion)
        self.present(alertaVC, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if contActualizaciones < 1 {
            let region = MKCoordinateRegion.init(center: ubicacion.location!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }else{
            ubicacion.startUpdatingLocation()
        }
//        print("Ubicacion actualizada")
    }
}

