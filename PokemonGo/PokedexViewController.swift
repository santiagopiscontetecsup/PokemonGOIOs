//
//  PokedexViewController.swift
//  PokemonGo
//
//  Created by Santiago Pisconte  on 13/11/24.
//

import UIKit

class PokedexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var PokemonsAtrapados:[Pokemon] = []
    var PokemonsNoAtrapados:[Pokemon] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PokemonsAtrapados = obtenerPokemonsAtrapados()
        PokemonsNoAtrapados = obtenerPokemonsNoAtrapados()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return indexPath.section == 0 ? .delete : .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                let pokemon = PokemonsAtrapados[indexPath.row]
                pokemon.atrapado = false
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                PokemonsAtrapados.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Atrapados"
        } else {
            return "No Atrapados"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return PokemonsAtrapados.count
        } else {
            return PokemonsNoAtrapados.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pokemon:Pokemon
        if indexPath.section == 0{
            pokemon = PokemonsAtrapados[indexPath.row]
        }else{
            pokemon = PokemonsNoAtrapados[indexPath.row]
        }
        
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(pokemon.nombre!) - Capturado: \(pokemon.contador) veces"
        cell.imageView?.image = UIImage(named: pokemon.imagenNombre!)
        return cell
    }
    
    @IBAction func mapTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
