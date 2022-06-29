//
//  TableViewController.swift
//  Soundboard
//
//  Created by lefevluc on 20/06/22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tabView: UITableView!
    
    var audioPlayer : AVAudioPlayer?
    var melodies : [Melody] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabView.dataSource = self
        tabView.delegate = self
    }
    
    //Chargement et affichage des melodies
    override func viewWillAppear(_ animated: Bool) {
        let context =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       
        do {
        melodies = try context.fetch(Melody.fetchRequest())
        tabView.reloadData()
        } catch {
            
        }
    }
    
    //Retourne le nombre de melodies pour l'affichage
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return melodies.count
    }
    
    //Affiche chaque melodie dans des cellules de la Table View
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let melody = melodies[indexPath.row]
        cell.textLabel?.text = String(melody.name!)
        return cell
    }
    
    //Permet de lire une melodie lorsque l'on clique dessus
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let melody = melodies[indexPath.row]
        do {
            audioPlayer = try AVAudioPlayer (data: melody.audio!)
            audioPlayer?.play()
        } catch {
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Permet de supprimer une melodie en glissant vers la gauche
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let melody = melodies[indexPath.row]
            context.delete(melody)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                   melodies = try context.fetch(Melody.fetchRequest())
                   tabView.reloadData()
                   } catch {
                       
                   }
            
        }
    }

}

